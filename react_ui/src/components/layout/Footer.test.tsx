import { render } from '@testing-library/react'
import React from 'react'

import { Footer } from './Footer'

it('shows the footer', () => {
  const { container } = render(<Footer />)

  expect(container).toMatchSnapshot()
})
