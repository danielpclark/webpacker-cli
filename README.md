[![Gem Version](https://badge.fury.io/rb/webpacker_cli.svg)](http://badge.fury.io/rb/webpacker_cli)
[![Build Status](https://github.com/danielpclark/webpacker-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/danielpclark/webpacker-cli/actions)

# WebpackerCli

**Webpacker's conventions for any framework, without Rails.**  Webpacker was abandoned by the Rails
team, and the old version of this tool depended on it (and on a mocked Rails app).  Version 1.0
removes that dependency entirely: the gem has **no runtime dependencies**, and drives plain
**Webpack 5** through a small, generated `webpack.config.js` that lives in your project.

You keep the parts of Webpacker that matter:

* `config/webpacker.yml` (`source_path`, `source_entry_path`, `public_output_path`, `extensions`, …)
* every file in `app/javascript/packs` is an entry point
* content-hashed output in `public/packs` plus a `manifest.json` for cache invalidation

## Prerequisites

Ruby 3.0+, Node.js 20.9+, and Yarn 1.x or npm.

## Installation

    $ gem install webpacker_cli

## Usage

    $ webpacker-cli init      # create config + entry pack + package.json, install Node packages
    $ webpacker-cli compile   # build packs into public/packs
    $ webpacker-cli watch     # rebuild on change
    $ webpacker-cli clobber   # remove compiled packs and cache
    $ webpacker-cli check     # verify prerequisites
    $ webpacker-cli info      # tool versions

The environment comes from `WEBPACKER_ENV`, `NODE_ENV` or `RAILS_ENV` (default `development`).
Production builds use content hashes and minification, e.g. `NODE_ENV=production webpacker-cli compile`.

The generated `config/webpack/webpack.config.js` and `package.json` are yours to edit: add a loader
by installing its package and adding a rule, and add the extension to `default.extensions` in
`config/webpacker.yml`.

> Server Tip: It is recommended to compile your assets upon deploy rather than per web request.

Route assets using `public/packs/manifest.json`:

    {
      "application.js": "/packs/application-9578bdd78b657fa4358f.js",
      "application.js.map": "/packs/application-9578bdd78b657fa4358f.js.map"
    }

## Staying current with Webpack

`package.json` pins each tool to a **major version range** (`webpack ^5`, `webpack-cli ^6`, …), so
`yarn upgrade`/`npm update` picks up fixes without breaking changes.  A new Webpack major is an
explicit, reviewed change to the templates in this gem (and to your project's config when you
choose to adopt it) — never a surprise.  Existing projects are never overwritten by `init` unless
you pass `--force`.

### Migrating from 0.x

The Rails mock (`Gemfile`, `Rakefile`, `bin/rails`, `config/application.rb`) and the `webpacker:*`
rake tasks are gone.  Delete those files, run `webpacker-cli init` for the new config, and move any
custom loaders from `config/webpack/loaders` into `webpack.config.js` rules.

## Example Integration

For a good example of using this tool for integrating with your own language see [webpacker-rs](https://github.com/danielpclark/webpacker-rs).  This library uses this tool to add Webpacker as part of the default build process of web deployment for the Rust language.  In essence the user theirself is responsible for running `webpacker-cli init` and then **webpacker-rs** has two methods for deployment which validate dependencies on the server and then compile the assets.  After deployment then **webpacker-rs** also provides a method for looking up the file mappings from the `manifest.json` file and provides a convenience helper method for dealing with the path routing.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielpclark/webpacker-cli

## License

The gem is available as open source under the terms of the [GNU Lesser General Public License version 3](https://opensource.org/licenses/LGPL-3.0).
