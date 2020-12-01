import { render } from '@testing-library/react'
import React from 'react'
import { MemoryRouter, Route } from 'react-router-dom'

import PrivateRoute from './PrivateRoute'
import { AuthenticationState } from './types'

const renderUI = (authState: AuthenticationState) =>
  render(
    <MemoryRouter initialEntries={['/secret']}>
      <PrivateRoute
        path="/secret"
        exact
        authState={authState}
        render={() => 'Secret stuff'}></PrivateRoute>
      <Route exact path="/sign-in">
        Sign in
      </Route>
    </MemoryRouter>
  )

it('redirects unknown users to sign-in', () => {
  const { container } = renderUI('unknown')
  expect(container).toMatchInlineSnapshot(`
    <div>
      Sign in
    </div>
  `)
})

it('redirects anonymous users to sign-in', () => {
  const { container } = renderUI('anonymous')
  expect(container).toMatchInlineSnapshot(`
    <div>
      Sign in
    </div>
  `)
})

it('allows authenticated users to see private routes', () => {
  const { container } = renderUI('authenticated')
  expect(container).toMatchInlineSnapshot(`
    <div>
      Sign in
    </div>
  `)
})
