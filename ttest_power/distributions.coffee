# log gamma function
# based on code from www.math.ucla.edu/~tom/distributions/beta.html
lgamma = (z) ->
    s=1+76.18009173/z-86.50532033/(z+1)+24.01409822/(z+2)-1.231739516/(z+3)+0.00120858003/(z+4)-0.00000536382/(z+5)
    (z-0.5)*Math.log(z+4.5)-(z+4.5)+Math.log(s*2.50662827465)

# utility function (not sure what this is!)
# based on code from www.math.ucla.edu/~tom/distributions/beta.html
betinc = (x, a, b, tol=1e-8) ->
    a0=0
    b0=1
    a1=1
    b1=1
    m9=0
    a2=0
    while Math.abs((a1-a2)/a1)>tol
        a2=a1
        c9=-(a+m9)*(a+b+m9)*x/(a+2*m9)/(a+2*m9+1)
        a0=a1+c9*a0
        b0=b1+c9*b0
        m9=m9+1
        c9=m9*(b-m9)*x/(a+2*m9-1)/(a+2*m9)
        a1=a0+c9*a1
        b1=b0+c9*b1
        a0=a0/b1
        b0=b0/b1
        a1=a1/b1
        b1=1
    a1/a

# error function
# from jStat: https://github.com/jstat/jstat/blob/master/src/special.js
# (MIT license)
erf = (x) ->
    cof = [-1.3026537197817094, 6.4196979235649026e-1, 1.9476473204185836e-2,
           -9.561514786808631e-3, -9.46595344482036e-4, 3.66839497852761e-4,
            4.2523324806907e-5, -2.0278578112534e-5, -1.624290004647e-6,
            1.303655835580e-6, 1.5626441722e-8, -8.5238095915e-8,
            6.529054439e-9, 5.059343495e-9, -9.91364156e-10,
           -2.27365122e-10, 9.6467911e-11, 2.394038e-12,
           -6.886027e-12, 8.94487e-13, 3.13092e-13,
           -1.12708e-13, 3.81e-16, 7.106e-15,
           -1.523e-15, -9.4e-17, 1.21e-16,
           -2.8e-17]
    j = cof.length - 1
    isneg = false
    d = 0
    dd = 0

    if x < 0
      x = -x
      isneg = true

    t = 2 / (2 + x)
    ty = 4 * t - 2

    while j > 0
        tmp = d
        d = ty * d - dd + cof[j]
        dd = tmp
        j -= 1

    res = t * Math.exp(-x * x + 0.5 * (cof[0] + ty * d) - dd)
    return res - 1 if isneg
    1 - res

# inverse of the complement of the error function
# from jStat: https://github.com/jstat/jstat/blob/master/src/special.js
# (MIT license)
erfcinv = (p) ->
    j = 0
    return -100 if p >= 2
    return  100 if p <= 0

    pp = if p < 1 then p else 2-p

    t = Math.sqrt(-2 * Math.log(pp / 2))
    x = -0.70711 * ((2.30753 + t * 0.27061) /
                  (1 + t * (0.99229 + t * 0.04481)) - t)
    while j < 2
        err = 1-erf(x) - pp
        x += err / (1.12837916709551257 * Math.exp(-x * x) - x * err)
        j += 1

    return x if p < 1
    -x

# CDF of beta distribution
pbeta = (x, a, b, tol=1e-8) ->
    if a <=0 or b <= 0
        console.log("pbeta: a and b must be positive")
        return null

    return 0 if x <= 0
    return 1 if x >= 1

    s = a+b
    bt = Math.exp(lgamma(s) - lgamma(b) - lgamma(a) +
             a*Math.log(x) + b*Math.log(1-x))

    return bt*betinc(x, a, b, tol) if x < (a+1)/(s+2)

    1 - bt*betinc(1-x, b, a, tol)

# normal density
dnorm = (x, mu=0, sd=1) ->
    x = parseFloat(x)
    mu = parseFloat(mu)
    sd = parseFloat(sd)
    if sd <= 0
        console.log("dnorm: sd must be positive")
        return null

    if Array.isArray(x)
        return (dnorm(xval, mu, sd) for xval in x)

    Math.exp(-0.5*Math.pow((x-mu)/sd, 2))/(sd * Math.sqrt(2*Math.PI))

# CDF of normal distribution
pnorm = (x, mu=0, sd=1) ->
    x = parseFloat(x)
    mu = parseFloat(mu)
    sd = parseFloat(sd)
    if sd <= 0
        console.log("pnorm: sd must be positive")
        return null
    if Array.isArray(x)
        return (dnorm(xval, mu, sd) for xval in x)

    z = (x - mu)/sd

    0.5 * (1 + erf(x/Math.sqrt(2)))

# quantile of normal distribution
qnorm = (p, mu=0, sd=1) ->
    p = parseFloat(p)
    mu = parseFloat(mu)
    sd = parseFloat(sd)
    if sd <= 0
        console.log("qnorm: sd must be positive")
        return null
    if p <= 0 or p >= 1
        console.log("qnorm: p must be in (0,1)")
        return null
    if Array.isArray(p)
        return (qnorm(pval, mu, sd) for pval in p)

    z = -1.41421356237309505 * erfcinv(2*p)

    z*sd + mu

# t density
dt = (x, df) ->
    x = parseFloat(x)
    df = parseFloat(df)
    if df <= 0
        console.log("dt: df must be positive")
        return null

    if Array.isArray(x)
        return (dt(xval, df) for xval in x)

    ldt = lgamma((df+1)/2) - 0.5*Math.log(df*Math.PI) -
        lgamma(df/2) - ((df+1)/2) * Math.log(1 + x*x/df)
    Math.exp(ldt)

# CDF of t distribution
pt = (x, df) ->
    x = parseFloat(x)
    df = parseFloat(df)
    if df <= 0
        console.log("dt: df must be positive")
        return null

    if Array.isArray(x)
        return (pt(xval, df) for xval in x)

    return 0.5 if x == 0
    y = 0.5 * pbeta(df/(x*x+df), df/2, 1/2)
    return y if x < 0
    1-y

# quantile of t distribution by binary search
qt = (p, df, hi=5, tol=0.0001) ->
    p = parseFloat(p)
    df = parseFloat(df)
    if df <= 0
        console.log("qt: df must be positive")
        return null

    if p <= 0 or p >= 1
        console.log("qt: p must be in (0,1)")
        return null

    lo = qnorm(p)

    # adjust hi if below quantile
    while pt(hi, df) <= p
        lo = hi
        hi += 1

    quant = (hi+lo)/2
    while hi-lo > tol
        if pt(quant, df) > p
            hi = quant
        else
            lo = quant
        quant = (hi+lo)/2

    quant

# non-central t distribution

# CDF of non-central t distribution
