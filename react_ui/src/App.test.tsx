import { render } from '@testing-library/react'
import React from 'react'

import App from './App'
import { Auth } from 'aws-amplify'
import { InMemoryCache } from 'apollo-boost'

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
  // expect(getByText('Sign up / Sign in')).toBeVisible()
  expect(queryByText('Log out')).toBeNull()

  // auth loads
  expect(await findByText('Log out')).toBeVisible()

  // chapter list loads
  expect(getByText('ChapterList')).toBeVisible()
})
