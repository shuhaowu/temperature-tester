### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 6630e5ec-b585-11eb-00c7-6f0e4cfe86e4
begin
	import Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 87e65d24-d605-4afc-bdc7-7b677af0aa72
begin
	Pkg.add("DataFrames")
	Pkg.add("CSV")
	Pkg.add("PyPlot")
	using DataFrames, CSV, PyPlot
	using Dates, Statistics
end

# ╔═╡ 50c3de39-f80c-4168-8610-215ebcf2b74a
begin
	default_header = ["Time", "Temp", "FreqMin", "FreqMax", "TestRunning"]
	function load_data(filename::String; header=default_header)
		df = DataFrame(
			CSV.File(
				filename; 
				header=header, 
				dateformat=dateformat"YYYY-mm-dd HH:MM:SS",
				types=Dict("Time" => Dates.DateTime)
			)
		)
		df.Time = map(Dates.value, df.Time .- df.Time[1]) ./ 1000
		df
	end
end

# ╔═╡ 08cf40fb-49cf-4cae-b010-e9697bb5ff0b
function load_multiple_dataframes(datafiles)
	dataframes = []
	
	for datafile in datafiles
		push!(dataframes, load_data(datafile["filename"]; header=datafile["header"]))
	end
	
	dataframes
end

# ╔═╡ 959f9723-78eb-4105-868e-c4d9eecc9bd1
function plot_comparison(datafiles, dataframes; time_limit, frequency_limit)
	fig = figure(figsize=[8, 8])
	ax = fig.add_subplot(2, 1, 1)
	ax2 = fig.add_subplot(2, 1, 2)
	
	lines = []
	
	for (i, df) in enumerate(dataframes)
		average_frequency = round(mean(df.FreqMax[df.TestRunning .== 1]) / 1000)
		
		(l, ) = ax.plot(df.Time, df.Temp, label=datafiles[i]["title"] * ": " * string(average_frequency) * "Mhz")
		ax2.plot(df.Time, df.FreqMax ./ 1000, ".")
				
		push!(lines, l)
	end
	
	ax.set_xlim(time_limit)
	ax2.set_xlim(time_limit)
	ax.set_ylim(20, 100)
	ax2.set_ylim(frequency_limit)
	
	ax2.set_xlabel("Time (s)")
	ax.set_ylabel("Temperature (C)")
	ax2.set_ylabel("Frequency (MHz)")
	
	ax2.legend(handles=lines, loc="lower right")
	
	fig.tight_layout()
	fig.subplots_adjust(hspace=0.1)
	fig
end

# ╔═╡ 80a3404d-65ad-4233-8547-0bfb5b0a0ef4
md"""
### ODroid XU4 passive vs active

This is done via the a copper heatsink designed for the Intel Northbridge chipset, instead of the stock fan/stock passive heatsink. My understanding is that the Northbridge heatsink performs similraly to the stock heatsink, which is validated by the plots below, as temperature with passive only goes to about 90C and the performance core frequency is throttled to about 1.4 - 1.5Ghz.

The fan is attached to the top of the Northbridge heatsink and is blowing air towards the CPU, which should be slightly better for cooling purposes. The fan is always running in this case, instead of being attached to the built-in fan port.
"""

# ╔═╡ d1a2865d-9570-446f-bed6-5eb000941736
begin
	odroid_datafiles = [
		Dict(
			"filename" => "data/odroid-northbridge-heatsink-5v-fan.csv",
			"title"    => "ODroid XU4 + Northbridge heatsink + 5V fan (always on)",
			"header"   => default_header,
		),
		Dict(
			"filename" => "data/odroid-northbridge-heatsink-test1.csv",
			"title"    => "ODroid XU4 + Northbridge heatsink (passive only)",
			"header"   => default_header,
		)
	]
	
	plot_comparison(odroid_datafiles, load_multiple_dataframes(odroid_datafiles); time_limit=(0, 1800), frequency_limit=(400, 2200))
end

# ╔═╡ b23c1fe1-b913-44c0-869b-2cb8c747d786
md"""
### Raspberry Pi 4 passive vs active
"""

# ╔═╡ 7147e094-6ae7-4588-a532-9ac249ab99e6
begin
	rpi_datafiles = [
		Dict(
			"filename" => "data/rpi4-3_3vfan-2_0ghz-suck.csv",
			"title"    => "Pi 4 2.0Ghz OC + 3.3V fan (suck)",
			# This is done with an older measure script.
			"header"   => ["Time", "Temp", "FreqMax", "Throttled", "TestRunning"],
		),
		Dict(
			"filename" => "data/rpi4-3_3vfan-2_0ghz-blow.csv",
			"title"    => "Pi 4 2.0Ghz OC + 3.3V fan (blow)",
			"header"   => default_header,
		),
		Dict(
			"filename" => "data/rpi4-5vfan-2_0ghz-blow.csv",
			"title"    => "Pi 4 2.0Ghz OC + 5V fan (blow)",
			"header"   => default_header,
		),
		Dict(
			"filename" => "data/rpi4-5vfan-alheatsink-2_0ghz-blow.csv",
			"title"    => "Pi 4 2.0Ghz OC + 5V fan (blow) + Al heatsink",
			"header"   => default_header,
		),
		Dict(
			"filename" => "data/rpi4-3.3vfan-alheatsink-2_0ghz-blow.csv",
			"title"    => "Pi 4 2.0Ghz OC + 3.3V fan (blow) + Al heatsink",
			"header"   => default_header,
		),
	]
	
	rpi_dataframes = load_multiple_dataframes(rpi_datafiles)
	plot_comparison(rpi_datafiles, rpi_dataframes; time_limit=(0, 1200), frequency_limit=(400, 2200))
end

# ╔═╡ Cell order:
# ╠═6630e5ec-b585-11eb-00c7-6f0e4cfe86e4
# ╠═87e65d24-d605-4afc-bdc7-7b677af0aa72
# ╟─50c3de39-f80c-4168-8610-215ebcf2b74a
# ╟─08cf40fb-49cf-4cae-b010-e9697bb5ff0b
# ╟─959f9723-78eb-4105-868e-c4d9eecc9bd1
# ╟─80a3404d-65ad-4233-8547-0bfb5b0a0ef4
# ╠═d1a2865d-9570-446f-bed6-5eb000941736
# ╠═b23c1fe1-b913-44c0-869b-2cb8c747d786
# ╠═7147e094-6ae7-4588-a532-9ac249ab99e6
