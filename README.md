# Xen Control Panel  


## Requirements  

1. Ruby > 1.9  
2. MongoDB  
3. Bundler (`gem install bundler`)

## Usage

For permanent usage run as a daemon or in a screen session.

For **development**:

  1. `bundle install`  
  2. `shotgun -o localhost -p 4567` (Replace localhost with a hostname or IP)

For **production**:  

  1. `bundle install`
  2. `puma config.ru`

## License

Copyright (c) 2014 Defined Code Ltd. See the LICENSE file for license rights and limitations (MIT).

## Contact

You can contact me [@Will3942](http://twitter.com/will3942) or [will@will3942.com](mailto:will@will3942.com)
