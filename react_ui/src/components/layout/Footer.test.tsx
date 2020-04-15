import { render } from '@testing-library/react'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'

import { Footer } from './Footer'

it('shows the footer', () => {
  const { container } = render(
    <MemoryRouter>
      <Footer />
    </MemoryRouter>
  )

  expect(container).toMatchSnapshot()
})
