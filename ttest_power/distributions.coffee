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
dnorm = (x, mu=100, sd=5) ->
    if sd <= 0
        console.log("dnorm: sd must be positive")
        return null

    if Array.isArray(x)
        return (dnorm(xval, mu, sd) for xval in x)

    Math.exp(-0.5*Math.pow((x-mu)/sd, 2))/(sd * Math.sqrt(2*Math.PI))

# quantile of standard normal distribution
qnorm = (p) ->
    split=0.42
    a0=  2.50662823884
    a1=-18.61500062529
    a2= 41.39119773534
    a3=-25.44106049637
    b1= -8.47351093090
    b2= 23.08336743743
    b3=-21.06224101826
    b4=  3.13082909833
    c0= -2.78718931138
    c1= -2.29796479134
    c2=  4.85014127135
    c3=  2.32121276858
    d1=  3.54388924762
    d2=  1.63706781897
    q=p-0.5
    if Math.abs(q)<=split
        r=q*q
        ppnd=q*(((a3*r+a2)*r+a1)*r+a0)/((((b4*r+b3)*r+b2)*r+b1)*r+1)
    else
        r=p
        r=1-p if q>0
        if r>0
            r=Math.sqrt(-Math.log(r))
            ppnd=(((c3*r+c2)*r+c1)*r+c0)/((d2*r+d1)*r+1)
            ppnd=-ppnd if q<0
        else
           ppnd=0

    ppnd

# t density
dt = (x, nu) ->
    if nu <= 0
        console.log("dt: nu must be positive")
        return null

    if Array.isArray(x)
        return (dt(xval, nu) for xval in x)

    ldt = lgamma((nu+1)/2) - 0.5*Math.log(nu*Math.PI) -
        lgamma(nu/2) - ((nu+1)/2) * Math.log(1 + x*x/nu)
    Math.exp(ldt)

# CDF of t distribution
pt = (x, nu) ->
    if nu <= 0
        console.log("dt: nu must be positive")
        return null

    if Array.isArray(x)
        return (pt(xval, nu) for xval in x)

    return 0.5 if x == 0
    y = 0.5 * pbeta(nu/(x*x+nu), nu/2, 1/2)
    return y if x < 0
    1-y

# quantile of t distribution by binary search
qt = (p, nu, hi=5, tol=0.0001) ->
    lo = qnorm(p)

    # adjust hi if below quantile
    while pt(hi, nu) <= p
        lo = hi
        hi += 1

    quant = (hi+lo)/2
    while hi-lo > tol
        if pt(quant, nu) > p
            hi = quant
        else
            lo = quant
        quant = (hi+lo)/2

    quant

# non-central t distribution

# CDF of non-central t distribution
