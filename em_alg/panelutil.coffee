# A variety of utility functions used by the different panel functions

# determine rounding of axis labels
formatAxis = (d, extra_digits=0) ->
    d = d[1] - d[0]
    ndig = Math.floor( Math.log(d % 10) / Math.log(10) )
    ndig = 0 if ndig > 0
    ndig = Math.abs(ndig) + extra_digits
    d3.format(".#{ndig}f")

# unique values of array (ignore nulls)
unique = (x) ->
    output = {}
    output[v] = v for v in x when v
    output[v] for v of output

# Pull out a variable (column) from a two-dimensional array
pullVarAsArray = (data, variable) ->
    v = []
    for i of data
        v = v.concat data[i][variable]
    v
  
# reorganize lod/pos by chromosome
# lodvarname==null    -> case for multiple LOD columns (lodheatmap)
# lodvarname provided -> case for one LOD column (lodchart)
reorgLodData = (data, lodvarname=null) ->
    data.posByChr = {}
    data.lodByChr = {}

    for chr,i in data.chrnames
        data.posByChr[chr] = []
        data.lodByChr[chr] = []
        for pos,j in data.pos
            if data.chr[j] == chr
                data.posByChr[chr].push(pos)
                data.lodnames = [data.lodnames] unless Array.isArray(data.lodnames)
                lodval = (data[lodcolumn][j] for lodcolumn in data.lodnames)
                data.lodByChr[chr].push(lodval)

    if lodvarname?
        data.markers = []
        for marker,i in data.markernames
            if marker != ""
                data.markers.push({name:marker, chr:data.chr[i], pos:data.pos[i], lod:data[lodvarname][i]})

    data

# calculate chromosome start/end + scales, for heat map
chrscales = (data, width, chrGap, leftMargin, pad4heatmap) ->
    # start and end of chromosome positions
    chrStart = []
    chrEnd = []
    chrLength = []
    totalChrLength = 0
    maxd = 0
    for chr in data.chrnames
        d = maxdiff(data.posByChr[chr])
        maxd = d if d > maxd

        rng = d3.extent(data.posByChr[chr])
        chrStart.push(rng[0])
        chrEnd.push(rng[1])
        L = rng[1] - rng[0]
        chrLength.push(L)
        totalChrLength += L

    # adjust lengths for heatmap
    if pad4heatmap
        data.recwidth = maxd
        chrStart = chrStart.map (x) -> x-maxd/2
        chrEnd = chrEnd.map (x) -> x+maxd/2
        chrLength = chrLength.map (x) -> x+maxd
        totalChrLength += (chrLength.length*maxd)

    # break up x axis into chromosomes by length, with gaps
    data.chrStart = []
    data.chrEnd = []
    cur = leftMargin
    cur += chrGap/2 unless pad4heatmap
    data.xscale = {}
    for chr,i in data.chrnames
        data.chrStart.push(cur)
        w = Math.round((width-chrGap*(data.chrnames.length-pad4heatmap))/totalChrLength*chrLength[i])
        data.chrEnd.push(cur + w)
        cur = data.chrEnd[i] + chrGap
        # x-axis scales, by chromosome
        data.xscale[chr] = d3.scale.linear()
                             .domain([chrStart[i], chrEnd[i]])
                             .range([data.chrStart[i], data.chrEnd[i]])

    # return data with new stuff added
    data

# Select a set of categorical colors
# ngroup is positive integer
# palette = "dark" or "pastel"
selectGroupColors = (ngroup, palette) ->
    return [] if ngroup == 0

    if palette == "dark"
        return ["slateblue"] if ngroup == 1
        return ["MediumVioletRed", "slateblue"] if ngroup == 2
        return colorbrewer.Set1[ngroup] if ngroup <= 9
        return d3.scale.category20().range()[0...ngroup]
    else
        return ["#bebebe"] if ngroup == 1
        return ["lightpink", "lightblue"] if ngroup == 2
        return colorbrewer.Pastel1[ngroup] if ngroup <= 9
        # below is rough attempt to make _big_ pastel palette
        return ["#8fc7f4", "#fed7f8", "#ffbf8e", "#fffbb8",
                "#8ce08c", "#d8ffca", "#f68788", "#ffd8d6",
                "#d4a7fd", "#f5f0f5", "#cc968b", "#f4dcd4",
                "#f3b7f2", "#f7f6f2", "#bfbfbf", "#f7f7f7",
                "#fcfd82", "#fbfbcd", "#87feff", "#defaf5"][0...ngroup]

# expand element/array (e.g., of colors) to a given length
#     single elment -> array, then repeated to length n
expand2vector = (input, n) ->
    return input unless input? # return null if null
    return input if Array.isArray(input) and input.length >= n
    input = [input] unless Array.isArray(input)
    input = (input[0] for i of d3.range(n)) if input.length == 1 and n > 1
    input

# median of a vector
median = (x) ->
    return null if !x? 
    n = x.length
    x.sort((a,b) -> a-b)
    if n % 2 == 1
        return x[(n-1)/2]
    (x[n/2] + x[(n/2)-1])/2

# given a vector of x's, return hash with values to left and right, and the differences
getLeftRight = (x) ->
    n = x.length
    x.sort( (a,b) -> a-b )

    xdif = []
    result = {}
    for v in x
        result[v] = {}

    for i in [1...n]
        xdif.push(x[i]-x[i-1])
        result[x[i]].left = x[i-1]
    for i in [0...(n-1)]
        result[x[i]].right = x[i+1]

    xdif = median(xdif)
    result.mediandiff = xdif

    result[x[0]].left = x[0]-xdif
    result[x[n-1]].right = x[n-1]+xdif
    result.extent = [x[0]-xdif/2, x[n-1]+xdif/2]

    result

# maximum difference between adjacent values in a vector
maxdiff = (x) ->
    return null if x.length < 2
    result = x[1] - x[0]
    return result if x.length < 3
    for i in [2...x.length]
        d = x[i] - x[i-1]
        result = d if d > result
    result

# matrix extent, min max
matrixMin = (mat) ->
    result = mat[0][0]
    for i of mat
        for j of mat[i]
            result = mat[i][j] if result > mat[i][j]
    result      

matrixMax = (mat) ->
    result = mat[0][0]
    for i of mat
        for j of mat[i]
            result = mat[i][j] if result < mat[i][j]
    result      

matrixMaxAbs = (mat) ->
    result = Math.abs(mat[0][0])
    for i of mat
        for j of mat[i]
            result = Math.abs(mat[i][j]) if result < mat[i][j]
    result      

matrixExtent = (mat) -> [matrixMin(mat), matrixMax(mat)]

d3.selection.prototype.moveToFront = () ->
    this.each () -> this.parentNode.appendChild(this)
  
d3.selection.prototype.moveToBack = () ->
    this.each () ->
        firstChild = this.parentNode.firstchild
        this.parentNode.insertBefore(this, firstChild) if firstChild

forceAsArray = (x) ->
    return x unless x? # if null, return null
    return x if Array.isArray(x)
    [x]

# any values in vec that appear in missing are made null
missing2null = (vec, missingvalues=['NA', '']) ->
    vec.map (value) -> if missingvalues.indexOf(value) > -1 then null else value

# display error at top of page
displayError = (message, divid=null) ->
    div = "div.error"
    div += "##{divid}" if divid?
    if d3.select(div).empty() # no errors yet
        d3.select("body")
          .insert("div", ":first-child")
          .attr("class", "error")
    d3.select(div)
      .append("p")
      .text(message)

# sum values in an array
sumArray = (vec) -> (vec.reduce (a,b) -> a+b)

# calculate cross-tabulation
calc_crosstab = (data) ->
    nrow = data.ycat.length
    ncol = data.xcat.length

    result = ((0 for col in [0..ncol]) for row in [0..nrow]) # matrix of 0's

    # count things up
    for i of data.x
        result[data.y[i]][data.x[i]] += 1

    # row and column sums
    rs = rowSums(result)
    cs = colSums(result)

    # fill in column sums
    for i in [0...ncol]
        result[nrow][i] = cs[i]

    # fill in row sums
    for i in [0...nrow]
        result[i][ncol] = rs[i]

    # fill in total
    result[nrow][ncol] = sumArray(rs)

    result

# rowSums: the sums for each row
rowSums = (mat) -> (sumArray(x) for x in mat)

# transpose: matrix transpose
transpose = (mat) -> ((mat[i][j] for i in [0...mat.length]) for j in [0...mat[0].length])

# colSums = the sums for each column
colSums = (mat) -> rowSums(transpose(mat))

# log base 2
log2 = (x) -> 
    return(x) unless x?
    Math.log(x)/Math.log(2.0)

# log base 10
log10 = (x) ->
    return(x) unless x?
    Math.log(x)/Math.log(10.0)

# absolute value, preserving nulls
abs = (x) -> 
    return(x) unless x?
    Math.abs(x)

