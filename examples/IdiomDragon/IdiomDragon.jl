### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ ada79ea0-f796-11ea-1aa2-eddd747b2c83
begin
	using Pkg; Pkg.activate("."); Pkg.instantiate()
	using PlutoUI
	using CEDICT
	using LightGraphs
	using Plots, GraphPlot
end

# ╔═╡ fc1f2d1e-f799-11ea-2606-f5046723c160
using LongestPaths

# ╔═╡ 6269f9b0-f778-11ea-2004-394d3bf5ff7c
md"""
# Making 成語接龍

## Idiom Source
Here, I've just filtered the CEDICT for only entries that have "(idiom)" in one of the definitions.
"""

# ╔═╡ 89e768e0-f775-11ea-02b9-5b07cf88d0b4
dict = load_dictionary();

# ╔═╡ 04c116f0-f77c-11ea-305e-cf13b0d83a8f
trad_idioms = [entry.trad for entry in search_senses(dict, "(idiom)")]

# ╔═╡ afabceb0-f778-11ea-0b9a-bb3cbcdf2836
md"""
## Creating the Graph
Now, to make the computations easier, I'm going to represent all the 成語 that I have in a graph. We could make the graph have an edge between idiom A and idiom B if the last character in A is the first character in B. There can be different ideas of being the "same": being the exact same character, have the exact same pronounciation, having the same primary pronounciation but a different tone, etc.

But this graph is awkward to create (to add an edge from an idiom, I need to scan through all the other **terminal characters** (ones either at the beginning or the end of idioms) to figure out which ones to add as destinations. This would be a slow $O(n^2)$ algorithm. Instead, the vertices will represent terminal characters, and an idiom is represented as an edge from its starting character to its ending character.

Because LightGraphs is optimized for integer-like vertices, first we'll create some mappings between the traditional terminal characters and the first $n$ positive natural numbers (where $n$ is the number of these characters).
"""

# ╔═╡ d62e2d50-f77b-11ea-0f69-ab7371ff50d6
terminal_chars = union(
	# initials
	Set(first(idiom) for idiom in trad_idioms),
	# finals
	Set(last(idiom) for idiom in trad_idioms)
)

# ╔═╡ e94d86d0-f783-11ea-0e6c-5d774a41d58c
num2term = collect(terminal_chars)

# ╔═╡ ef8a82f0-f783-11ea-3e6c-d5591033c789
term2num = Dict(term_char => UInt16(index) for (index, term_char) in pairs(num2term))

# ╔═╡ 85e6c400-f77c-11ea-27f5-e7f9846cadcb
let num_idioms = length(trad_idioms), num_term_chars = length(terminal_chars)
	md"""
	*Brief aside*: It's a little interesting to me that even though there are $num_idioms idioms in the dictionary, there are only $num_term_chars total terminal characters. That means on average each terminal character is repeated $(round(2*num_idioms/num_term_chars; digits=2)) times.
	"""
end

# ╔═╡ 021f2dce-f77a-11ea-3bc3-1770604ce10a
idiom_graph = SimpleDiGraph(UInt16(length(terminal_chars)));

# ╔═╡ 3417ba30-f786-11ea-2d30-a9df1f9ca6a0
edge_idioms = Dict{Tuple{Char, Char}, Vector{String}}();

# ╔═╡ c670e330-f776-11ea-22c6-598dabb22ca4
for idiom in trad_idioms
	edge = (first(idiom), last(idiom))
	add_edge!(idiom_graph, term2num[first(edge)], term2num[last(edge)])

	if haskey(edge_idioms, edge)
		push!(edge_idioms[edge], idiom)
	else
		edge_idioms[edge] = [idiom]
	end

end

# ╔═╡ dd133a30-f784-11ea-1d08-c9224043fcd8
md"""
Now to use the graph to access information about the connectedness of different idioms, we can do things like query the neighbors (converting between our graph vertices as needed).
"""

# ╔═╡ 9d70c340-f787-11ea-3b52-4302490de06a
initial = '叫';

# ╔═╡ e7634a5e-f780-11ea-1bab-8308a9188fd7
initial_outneighbors = num2term[outneighbors(idiom_graph, term2num[initial])]

# ╔═╡ 0a65dba2-f785-11ea-2112-ad09bee3f657
md"""
Here, this means that there are idioms that start with 叫 and end with either 天 or 迭. To see which ones, we'll have to query the `edge_idioms` dictionary.
"""

# ╔═╡ a1395970-f786-11ea-3273-c3cabe974073
[edge_idioms[(initial, final)] for final in initial_outneighbors]

# ╔═╡ 863059b0-f788-11ea-1466-173304238a3c
md"""
So there are two idioms for each final terminal character in this case.

We can also figure out what idioms end with that character.
"""

# ╔═╡ d8490b20-f788-11ea-0dc4-f31128f26958
initial_inneighbors = num2term[inneighbors(idiom_graph, term2num[initial])]

# ╔═╡ edda218e-f788-11ea-087e-63329996b830
[edge_idioms[(final, initial)] for final in initial_inneighbors]

# ╔═╡ 207b4070-f789-11ea-2f23-6945d91c5dc7
md"""
## Basic Chains
We can just iterate through the graph, choosing a random path to go down in order to create some Markov chain dragons.

First, let's figure out how to get to the next idiom.
"""

# ╔═╡ 59036480-f78f-11ea-1d45-9f33c884a7d1
function random_idiom(prev_idiom)
	# get the last character of the previous idiom
	first_char = last(prev_idiom)

	# all possible end characters
	end_chars = outneighbors(idiom_graph, term2num[first_char])
	length(end_chars) == 0 && return nothing

	# out of all possible end characters, choose a random one
	last_char = num2term[rand(end_chars)]

	# all possible idioms that start and end with these characters
	possible_idioms = edge_idioms[(first_char, last_char)]
	length(possible_idioms) == 0 && return nothing

	# choose randomly from all possible idioms that start and end with these chars
	rand(possible_idioms)
end;

# ╔═╡ d3786f40-f793-11ea-28f4-83043da67d5c
md"""
(A slight issue with this implementation is that all idioms starting with a certain character are not necessarily chosen with equal probability.)

Now, let's try it out on some idioms from our list.
"""

# ╔═╡ 6b7a0340-f789-11ea-2677-b967a8665cce
initial_idiom = rand(trad_idioms)

# ╔═╡ fbc7ad60-f790-11ea-2396-2d60b71ebb36
random_idiom(initial_idiom)

# ╔═╡ 73a9207e-f78b-11ea-3bd3-29cc530a2cdb
md"To make it repeat the process..."

# ╔═╡ 7adba030-f78b-11ea-2833-6d4cfe471978
function random_idiom_walk(idiom, len = 100)
	idioms = Vector{String}()
	i = 0
	while idiom != nothing && i <= len
		push!(idioms, idiom)
		i += 1
		idiom = random_idiom(idiom)
	end
	idioms
end;

# ╔═╡ a2c3faa0-f792-11ea-01c6-1fa82522f5ea
random_idiom_walk(initial_idiom)

# ╔═╡ 97e74cc0-f794-11ea-25f5-e73f194a7d6e
md"""
Wait a minute! These are all really short! It's really hard to actually connect them, even when repeating this experiment many times:
"""

# ╔═╡ 87d1cc50-f796-11ea-1777-1f8e16901fd9
maximum(length.(random_idiom_walk.(rand(trad_idioms, 100))))

# ╔═╡ a4cd7ee0-f795-11ea-0532-211a33e21562
md"""
Let's plot the distributions as histograms to see what's going on.
"""

# ╔═╡ c109a010-f796-11ea-170b-5de0f28d25b3
md"""
Number of Samples:
$(@bind samples Slider(10:2000, default=20, show_value=true))
"""

# ╔═╡ d1048c40-f797-11ea-3c3d-6383874745c1
md"""
Maximum Number of Iterations:
$(@bind len Slider(20:500, default=250, show_value=true))
"""

# ╔═╡ 56e84882-f796-11ea-0720-d1ee3698265e
histogram(length.(random_idiom_walk.(rand(trad_idioms, samples), len)), bins=15)

# ╔═╡ 13bf3850-f798-11ea-0591-57e00345f4c2
md"""
So it's very rare in general that we ever hit the limit on the number of iterations. Although when we do, we *really* hit it, so maybe there's something else going on, like it's a cycle in the graph (which we currently don't detect).
"""

# ╔═╡ e96e21a0-f798-11ea-3f54-ff0b05d1eb35
md"""
# Longest Cycles & Paths
If we want to prove there is a cycle, the easiest way is to see if there's an idiom that starts and ends with the same character (these are actually already excluded as LightGraphs graphs by default exclude self-loops).
"""

# ╔═╡ 42d03620-f799-11ea-3669-69a09bd1facf
[idiom for idiom in trad_idioms if first(idiom) == last(idiom)]

# ╔═╡ c4de4760-f799-11ea-21cf-d9d374c89e67
md"""
Voila! So there are already some self-loops (technically, we could have self-loops, but no cycles of length 2, but that's unlikely, so we'll just keep moving on).

What's more interesting is the longest cycle in this graph. However, this (and the similar longest path problem) is an NP-hard problem. We can still try the brute force method and hope our graph is sufficiently small and well-behaved.
"""

# ╔═╡ 1aa5b380-f79b-11ea-0a27-b5b7d7091b9f
find_longest_cycle(idiom_graph)

# ╔═╡ 33068bc0-f79b-11ea-1c88-e9d151c04ead
find_longest_path(idiom_graph)

# ╔═╡ cafc4c00-f7a8-11ea-205d-2f425d554032
gplot(idiom_graph)

# ╔═╡ Cell order:
# ╠═ada79ea0-f796-11ea-1aa2-eddd747b2c83
# ╟─6269f9b0-f778-11ea-2004-394d3bf5ff7c
# ╠═89e768e0-f775-11ea-02b9-5b07cf88d0b4
# ╠═04c116f0-f77c-11ea-305e-cf13b0d83a8f
# ╟─afabceb0-f778-11ea-0b9a-bb3cbcdf2836
# ╠═d62e2d50-f77b-11ea-0f69-ab7371ff50d6
# ╠═e94d86d0-f783-11ea-0e6c-5d774a41d58c
# ╠═ef8a82f0-f783-11ea-3e6c-d5591033c789
# ╟─85e6c400-f77c-11ea-27f5-e7f9846cadcb
# ╠═021f2dce-f77a-11ea-3bc3-1770604ce10a
# ╠═3417ba30-f786-11ea-2d30-a9df1f9ca6a0
# ╠═c670e330-f776-11ea-22c6-598dabb22ca4
# ╟─dd133a30-f784-11ea-1d08-c9224043fcd8
# ╠═9d70c340-f787-11ea-3b52-4302490de06a
# ╠═e7634a5e-f780-11ea-1bab-8308a9188fd7
# ╟─0a65dba2-f785-11ea-2112-ad09bee3f657
# ╠═a1395970-f786-11ea-3273-c3cabe974073
# ╟─863059b0-f788-11ea-1466-173304238a3c
# ╠═d8490b20-f788-11ea-0dc4-f31128f26958
# ╠═edda218e-f788-11ea-087e-63329996b830
# ╟─207b4070-f789-11ea-2f23-6945d91c5dc7
# ╠═59036480-f78f-11ea-1d45-9f33c884a7d1
# ╟─d3786f40-f793-11ea-28f4-83043da67d5c
# ╠═6b7a0340-f789-11ea-2677-b967a8665cce
# ╠═fbc7ad60-f790-11ea-2396-2d60b71ebb36
# ╟─73a9207e-f78b-11ea-3bd3-29cc530a2cdb
# ╠═7adba030-f78b-11ea-2833-6d4cfe471978
# ╠═a2c3faa0-f792-11ea-01c6-1fa82522f5ea
# ╟─97e74cc0-f794-11ea-25f5-e73f194a7d6e
# ╠═87d1cc50-f796-11ea-1777-1f8e16901fd9
# ╟─a4cd7ee0-f795-11ea-0532-211a33e21562
# ╟─c109a010-f796-11ea-170b-5de0f28d25b3
# ╟─d1048c40-f797-11ea-3c3d-6383874745c1
# ╠═56e84882-f796-11ea-0720-d1ee3698265e
# ╟─13bf3850-f798-11ea-0591-57e00345f4c2
# ╟─e96e21a0-f798-11ea-3f54-ff0b05d1eb35
# ╟─42d03620-f799-11ea-3669-69a09bd1facf
# ╟─c4de4760-f799-11ea-21cf-d9d374c89e67
# ╠═fc1f2d1e-f799-11ea-2606-f5046723c160
# ╠═1aa5b380-f79b-11ea-0a27-b5b7d7091b9f
# ╠═33068bc0-f79b-11ea-1c88-e9d151c04ead
# ╠═cafc4c00-f7a8-11ea-205d-2f425d554032
