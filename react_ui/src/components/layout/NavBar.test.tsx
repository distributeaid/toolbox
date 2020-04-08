import { fireEvent, render } from '@testing-library/react'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'

import { NavBar } from './NavBar'

it('shows the nav bar', () => {
  const { container } = render(
    <MemoryRouter>
      <NavBar onSignOut={jest.fn()} authState="anonymous" />
    </MemoryRouter>
  )

  expect(container).toMatchSnapshot()
})

it('signs out when clicked', () => {
  const onSignOut = jest.fn()
  const { getByText } = render(
    <MemoryRouter>
      <NavBar onSignOut={onSignOut} authState="authenticated" />
    </MemoryRouter>
  )

  fireEvent.click(getByText('Log out'))
  expect(onSignOut).toHaveBeenCalled()
})

it('shows a sign in link when anonymous', () => {
  const { getByText } = render(
    <MemoryRouter>
      <NavBar onSignOut={jest.fn()} authState="anonymous" />
    </MemoryRouter>
  )

  expect(getByText('Sign up / Sign in')).toBeVisible()
})
