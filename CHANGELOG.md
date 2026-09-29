# Changelog

## 1.0.0

Complete rewrite; no longer depends on Webpacker or Rails.

- Drives Webpack 5 directly through a generated, editable `config/webpack/webpack.config.js`.
- No runtime gem dependencies.
- `init` generates `config/webpacker.yml`, an entry pack and `package.json`; existing files are kept unless `--force`.
- New commands: `compile`, `watch`, `clobber`, `check`, `info`, `version`.
- `public/packs/manifest.json` keeps its flat `"application.js" => "/packs/application-<hash>.js"` format.
- **Breaking:** the `webpacker:*` rake tasks and the generated `Gemfile`, `Rakefile`, `bin/rails`, `config/application.rb` and `config/webpack/loaders` are gone. Requires Ruby >= 3.0 and Node >= 20.9.

## 0.9.4 and earlier

Mocked a Rails app to run Webpacker 4's rake tasks.
