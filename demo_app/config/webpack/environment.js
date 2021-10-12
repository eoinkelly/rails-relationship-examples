'use strict';

const { environment } = require('@rails/webpacker');
const Dotenv = require('dotenv-webpack');

environment.plugins.prepend('Dotenv', new Dotenv());

module.exports = environment;
