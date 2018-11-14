[![Gem Version](https://badge.fury.io/rb/webpacker-cli.svg)](http://badge.fury.io/rb/webpacker-cli)
[![Build Status](https://travis-ci.org/danielpclark/webpacker-cli.svg)](https://travis-ci.org/danielpclark/webpacker-cli)

# WebpackerCli

Bringing the impressive work of the Rails' **Webpacker** project **to be available for frameworks
other than Rails**.  This is done by mocking the minimal amount of Rails for the Webpacker's
Rake commands to be able to run.

Webpacker itself takes Webpack, which has a primary focus for pre-processing JavaScript related
code, and make pre-processing other kinds of files such as Css, Sass, Images, Vue, React,
CoffeeScript, and other similar content as simple as a couple very minor edits.  Without Webpacker
you would need to go through quite a bit of extra work to get Webpack to handle non JS items.

This project makes asset packing and cache invalidation easy for any web framework by bringing
Webpacker's tooling to the command line.

## Installation

Install it yourself as:

    $ gem install webpacker_cli

## Usage

General help is found with

    $ webpacker-cli --help

The help menu will change after initialization within the project directory.

And get started using it in your target project with:

    $ webpacker-cli init

This creates the minimum files for Webpacker to work and runs `bundle` & `rake webpacker:install`.
From here you have your configuration files for Webpack/Webpacker in the `config` directory.

To compile your assets you may now run:

    $ webpacker-cli compile

To add support for another file type you can add a file to the `config/webpack/loaders`
directory.  Then load it from `config/webpack/environment.js` and lastly add the file extension
to the `config/webpacker.yml` under `default.extensions`.  Be sure to add the JS package with
a command like `yarn add`.

> Server Tip: It is recommended to compile your assets upon deploy rather than per web request.

Once your assets are compiled for deployment you will need to have your web application route
the assets by the file stored in `public/packs/manifest.json` which will look similar to:

    {
      "application.js": "/packs/application-9578bdd78b657fa4358f.js",
      "application.js.map": "/packs/application-9578bdd78b657fa4358f.js.map"
    }

This way Webpacker handles cache invalidation for you whenever you make changes to your assets.
So the `manifest.json` is the key-value pair of data used to be substitued in your web page views
for the `src` references.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielpclark/webpacker-cli

## License

The gem is available as open source under the terms of the [GNU Lesser General Public License version 3](https://opensource.org/licenses/LGPL-3.0).
