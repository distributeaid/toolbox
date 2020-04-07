import { render } from '@testing-library/react'
import React from 'react'

import App from './App'

test.skip('renders learn react link', () => {
  const { getByText } = render(<App />)
  const linkElement = getByText('Home')
  expect(linkElement).toBeInTheDocument()
})
