import { render } from '@testing-library/react'
import { Auth } from 'aws-amplify'
import React from 'react'

import App from './App'

jest.mock('aws-amplify')
jest.mock('aws-amplify-react')
jest.mock('./pages/ChapterList', () => ({
  ChapterList: () => <div>ChapterList</div>,
}))

it('loads authentication state from aws & displays logged in state', async () => {
  ;(Auth.currentAuthenticatedUser as jest.Mock).mockReturnValueOnce(
    Promise.resolve()
  )

  const { getByText, findByText, queryByText } = render(<App />)
  expect(getByText('Loading...')).toBeVisible()
  expect(queryByText('Log out')).toBeNull()

  // auth loads
  expect(await findByText('Log out')).toBeVisible()

  // chapter list loads
  expect(getByText('ChapterList')).toBeVisible()
})

it('loads authentication state from aws & displays sign in link', async () => {
  ;(Auth.currentAuthenticatedUser as jest.Mock).mockReturnValueOnce(
    Promise.reject()
  )

  const { getByText, findByText, queryByText } = render(<App />)
  expect(getByText('Loading...')).toBeVisible()
  expect(queryByText('Log out')).toBeNull()

  // auth loads
  expect(await findByText('Sign up / Sign in')).toBeVisible()
  expect(queryByText('Log out')).toBeNull()

  // chapter list loads
  expect(getByText('ChapterList')).toBeVisible()
})
