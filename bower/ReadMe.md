## Bower to grab javascript libraries

I use [bower](http://bower.io/) (a packaging system for javascript) to
grab d3, jquery, jquery-ui, d3-tip, and d3panels. The
[`bower/bower.json`](https://github.com/kbroman/d3examples/tree/master/bower/bower.json)
file indicates the libraries (and minimal versions) to get.

- To install bower, you need [npm](https://www.npmjs.com/) (the
  [node](https://nodejs.org/download/) package manager)

      npm install -g bower

- Install these packages (indicated within the `bower.json` file)

        bower install

- To update the packages

        bower update
