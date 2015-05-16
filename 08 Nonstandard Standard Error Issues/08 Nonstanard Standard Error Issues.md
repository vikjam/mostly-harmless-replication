# 08 Nonstandard Standard Error Issues
## 8.1 The Bias of Robust Standard Errors

### Table 8.1.1
Completed in [Stata](Table%208-1-1.do), [R](Table%208-1-1.r), [Python](Table%208-1-1.py) and [Julia](Table%208-1-1.jl)

_Panel A: Lots of Heteroskedasticity_

|Estimate               |   Mean|   Std| Normal|     t|
|:----------------------|------:|-----:|------:|-----:|
|Beta_1                 | -0.006| 0.581|     NA|    NA|
|Conventional           |  0.331| 0.052|  0.269| 0.249|
|HC0                    |  0.433| 0.210|  0.227| 0.212|
|HC1                    |  0.448| 0.218|  0.216| 0.201|
|HC2                    |  0.525| 0.260|  0.171| 0.159|
|HC3                    |  0.638| 0.321|  0.124| 0.114|
|max(Conventional, HC0) |  0.461| 0.182|  0.174| 0.159|
|max(Conventional, HC1) |  0.474| 0.191|  0.167| 0.152|
|max(Conventional, HC2) |  0.543| 0.239|  0.136| 0.123|
|max(Conventional, HC3) |  0.650| 0.305|  0.101| 0.091|

_Panel B: Little Heteroskedasticity_

|Estimate               |   Mean|   Std| Normal|     t|
|:----------------------|------:|-----:|------:|-----:|
|Beta_1                 | -0.006| 0.595|     NA|    NA|
|Conventional           |  0.519| 0.070|  0.097| 0.084|
|HC0                    |  0.456| 0.200|  0.204| 0.188|
|HC1                    |  0.472| 0.207|  0.191| 0.175|
|HC2                    |  0.546| 0.251|  0.153| 0.140|
|HC3                    |  0.656| 0.312|  0.112| 0.102|
|max(Conventional, HC0) |  0.569| 0.130|  0.081| 0.070|
|max(Conventional, HC1) |  0.577| 0.139|  0.079| 0.067|
|max(Conventional, HC2) |  0.625| 0.187|  0.068| 0.058|
|max(Conventional, HC3) |  0.712| 0.260|  0.054| 0.045|

_Panel C: No Heteroskedasticity_

|Estimate               |   Mean|   Std| Normal|     t|
|:----------------------|------:|-----:|------:|-----:|
|Beta_1                 | -0.006| 0.604|     NA|    NA|
|Conventional           |  0.603| 0.081|  0.059| 0.049|
|HC0                    |  0.469| 0.196|  0.193| 0.177|
|HC1                    |  0.485| 0.203|  0.180| 0.165|
|HC2                    |  0.557| 0.246|  0.145| 0.131|
|HC3                    |  0.667| 0.308|  0.106| 0.097|
|max(Conventional, HC0) |  0.633| 0.116|  0.052| 0.043|
|max(Conventional, HC1) |  0.639| 0.123|  0.051| 0.042|
|max(Conventional, HC2) |  0.678| 0.166|  0.045| 0.036|
|max(Conventional, HC3) |  0.752| 0.237|  0.036| 0.030|
