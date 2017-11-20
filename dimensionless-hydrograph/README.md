# gutsy-api

>

## About

This project uses [NodeJS](https://nodejs.org/), [ExpressJS](https://expressjs.com/), [Sequelize](http://docs.sequelizejs.com/), and [Postgres](https://www.postgresql.org/).

## Getting Started

1. Install [NodeJS](https://nodejs.org/), [npm](https://www.npmjs.com/) installed and [yarn](https://yarnpkg.com/en/).
2. Install your dependencies

    ```
    cd path/to/gutsy-api; yarn
    ```

3. Start your app

    ```
    yarn start
    ```

## Testing

Simply run `yarn test` and all your tests in the `test/` directory will be run.

## Sequelize CLI

```
$ npm install -g sequelize-cli

$ sequelize model:create --name TodoItem --attributes content:string,complete:boolean #Generate a model
```

## Help

For more information on all the things you can do with Sequelize CLI visit [sequelize cli ](https://github.com/sequelize/cli).

## Changelog

__0.1.0__

- Initial release

## License

Copyright (c) 2016

Licensed under the [MIT license](LICENSE).
