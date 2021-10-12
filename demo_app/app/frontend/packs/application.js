// The application.js pack is defered by default which means that nothing imported
// in this file will begin executing until after the page has loaded. This helps to
// speed up page loading times, especially in apps that have large amounts of js.
//
// If you have javascript that *must* execute before the page has finished loading,
// create a separate 'boot.js' pack in the frontend/packs directory and import any
// required files in that. Also remember to add a separate pack_tag entry with:
// <%= javascript_pack_tag "boot", "data-turbolinks-track": "reload" %>
// to the views/layouts/application.html.erb file above the existing application pack tag.
//
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import * as ActiveStorage from '@rails/activestorage';
import Rails from '@rails/ujs';
import * as Sentry from '@sentry/browser';
import Turbolinks from 'turbolinks';
import 'channels';

Rails.start();
Turbolinks.start();
ActiveStorage.start();

import '../stylesheets/application.scss';

// Initialize Sentry Error Reporting
//
// Import all your application's JS after this section because we need Sentry
// to be initialized **before** we import any of our actual JS so that Sentry
// can report errors from it.
//
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.SENTRY_ENV || process.env.RAILS_ENV
});

// Uncomment this Sentry by sending an exception every time the page loads.
// Obviously this is a very noisy activity and we do have limits on Sentry so
// you should never do this on a deployed environment.
//
// Sentry.captureException(new Error('Away-team to Enterprise, two to beam directly to sick bay...'));

// Import all your application's JS here
//
// import '../javascript/example-1.js';
// import { someFunc } from '../javascript/funcs.js';
