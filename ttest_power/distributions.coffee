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
    if Array.isArray(x)
        return (dnorm(xval, mu, sd) for xval in x)

    Math.exp(-0.5*Math.pow((x-mu)/sd, 2))/(sd * Math.sqrt(2*Math.PI))
