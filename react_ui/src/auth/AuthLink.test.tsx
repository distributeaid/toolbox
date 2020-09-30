import { fireEvent, render, waitFor } from '@testing-library/react'
import { Auth } from 'aws-amplify'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'

import { AuthLink } from './AuthLink'

jest.mock('aws-amplify')

it('loads authentication state from aws & displays logged in state', async () => {
  ;(Auth.currentAuthenticatedUser as jest.Mock).mockReturnValueOnce(
    Promise.resolve()
  )

  const { getByText, findByText, queryByText } = render(
    <MemoryRouter>
      <AuthLink />
    </MemoryRouter>
  )
  expect(queryByText('auth.signOut')).toBeNull()

  // auth loads
  expect(await findByText('auth.signOut')).toBeVisible()
  expect(queryByText('auth.signIn')).toBeNull()
  ;(Auth.signOut as jest.Mock).mockReturnValueOnce(Promise.resolve())
  fireEvent.click(getByText('auth.signOut'))

  expect(Auth.signOut).toHaveBeenCalled()
  await waitFor(() => expect(window.location.pathname).toEqual('/'))
})

it('loads authentication state from aws & displays sign in link', async () => {
  ;(Auth.currentAuthenticatedUser as jest.Mock).mockReturnValueOnce(
    Promise.reject()
  )

  const { findByText, queryByText } = render(
    <MemoryRouter>
      <AuthLink />
    </MemoryRouter>
  )
  expect(queryByText('auth.signIn')).toBeNull()

  // auth loads
  expect(await findByText('auth.signIn')).toBeVisible()
  expect(queryByText('auth.signOut')).toBeNull()
})
