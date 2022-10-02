# Load packages
using FileIO, StatFiles, DataFrames, CategoricalArrays
using FixedEffectModels
using Gadfly
using Cairo

# Download the data and unzip it
download(
    "https://www.dropbox.com/s/m6o0704ohzwep4s/outsourcingatwill_table7.zip?dl=1",
    "outsourcingatwill_table7.zip",
)
run(`unzip -o outsourcingatwill_table7.zip`)

# Import data
autor = DataFrame(load("table7/autor-jole-2003.dta"));

# Log total employment: from BLS employment & earnings
autor.lnemp = log.(autor.annemp);

# Non-business-service sector employment from CBP
autor.nonemp = autor.stateemp .- autor.svcemp;
autor.lnnon = log.(autor.nonemp);
autor.svcfrac = autor.svcemp ./ autor.nonemp;

# Total business services employment from CBP
autor.bizemp = autor.svcemp .+ autor.peremp
autor.lnbiz = log.(autor.bizemp)

# Restrict sample
autor = autor[autor.year.>=79, :];
autor = autor[autor.year.<=95, :];
autor = autor[autor.state.!=98, :];

# State dummies, year dummies, and state*time trends
autor.t = autor.year .- 78;
autor.t2 = autor.t .^ 2;

# Generate more aggregate demographics
autor.clp = autor.clg .+ autor.gtc;
autor.a1624 = autor.m1619 .+ autor.m2024 .+ autor.f1619 .+ autor.f2024;
autor.a2554 = autor.m2554 .+ autor.f2554;
autor.a55up = autor.m5564 .+ autor.m65up .+ autor.f5564 .+ autor.f65up;
autor.fem = autor.f1619 .+ autor.f2024 .+ autor.f2554 .+ autor.f5564 .+ autor.f65up;
autor.white = autor.rs_wm .+ autor.rs_wf;
autor.black = autor.rs_bm .+ autor.rs_bf;
autor.other = autor.rs_om .+ autor.rs_of;
autor.married = autor.marfem .+ autor.marmale;

# Create categorical variable for state and year
autor.state_c = categorical(autor.state);
autor.year_c = categorical(autor.year);

# Diff-in-diff regression
did = reg(
    autor,
    @formula(
        lnths ~
            lnemp +
            admico_2 + admico_1 + admico0 + admico1 + admico2 + admico3 + mico4 +
            admppa_2 + admppa_1 + admppa0 + admppa1 + admppa2 + admppa3 + mppa4 +
            admgfa_2 + admgfa_1 + admgfa0 + admgfa1 + admgfa2 + admgfa3 + mgfa4 +
            fe(state_c) + fe(year_c) + fe(state_c)&t
    ),
    Vcov.cluster(:state_c),
)

# Store results in a DataFrame for a plot
results_did = DataFrame(
    label = coefnames(did),
    coef  = coef(did) .* 100,
    se    = stderror(did) .* 100
);

# Keep only the relevant coefficients
results_did = filter(r -> any(occursin.(r"admico|mico", r.label)), results_did);

# Define labels for coefficients
results_did.label .= [
    "2 yr prior",
    "1 yr prior",
    "Yr of adopt",
    "1 yr after",
    "2 yr after",
    "3 yr after",
    "4+ yr after",
];

# Make plot
figure = plot(
    results_did,
    x = "label",
    y = "coef",
    ymin = results_did.coef .- 1.96 .* results_did.se,
    ymax = results_did.coef .+ 1.96 .* results_did.se,
    Geom.point,
    Geom.line,
    Geom.errorbar,
    Guide.xlabel(
        "Time passage relative to year of adoption " *
        "of implied contract exception",
    ),
    Guide.ylabel("Log points"),
);

# Export figure
draw(PNG("Figure 5-2-4-Julia.png", 7inch, 6inch), figure);
