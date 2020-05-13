# Logistics platform UI

## Available Scripts

### `npm start`

Runs the app in the development mode.<br /> Open
[http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br /> You will also see any lint errors
in the console.

### `npm test`

Launches the test runner in the interactive watch mode.<br /> See the section
about
[running tests](https://facebook.github.io/create-react-app/docs/running-tests)
for more information.

### `npm test -- -u`

Same as `npm test` but regenerates the Jest snapshots from the current code.
Only do this after manually verifying the page is rendering as intended.

### `npm run build`

Builds the app for production to the `build` folder.<br /> It correctly bundles
React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br /> Your app is
ready to be deployed!

See the section about
[deployment](https://facebook.github.io/create-react-app/docs/deployment) for
more information.

### `npm run lint`

Lints the code and applies fixes, if autofixable.

### `npm run codegen`

Regenerates `src/generated/graphql.ts` from the server schema. Requires server
to be running.

## Technologies

- [React](https://reactjs.org/) _View rendering_
- [Tailwind CSS](https://tailwindcss.com/) _Styling_
- [Apollo Client](https://www.apollographql.com/docs/react/) _GraphQL API client
  & state management_
- [Formik](https://jaredpalmer.com/formik/) _Form state handling_
- [Yup](https://github.com/jquense/yup) _Validation_
- [react-i18next](https://react.i18next.com/)
  _Internationalization/localization_

### Infrastructure:

- [Create React App](https://github.com/facebook/create-react-app) _Default
  configuration & scripts_
- [npm](https://www.npmjs.com/) _Package manager_
- [Webpack](https://webpack.js.org/) _Build system_
- [TypeScript](https://www.typescriptlang.org/) _Strongly-typed JavaScript_
- [Prettier](https://prettier.io/) _Code formatter_
- [ESLint](https://eslint.org/) _Linter_
- [GraphQL Code Generator](https://github.com/dotansimha/graphql-code-generator)
  _Generates TypeScript types based on the server's GraphQL API schema_

### Testing:

- [Cypress](https://www.cypress.io/) _End-to-end test framework_
- [Jest](https://jestjs.io/) _Unit test framework_
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro)
  _React/browser interaction test helpers_
