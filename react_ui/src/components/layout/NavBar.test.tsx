import { render } from '@testing-library/react'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'

import { NavBar } from './NavBar'

it('shows the nav bar', () => {
  const { container } = render(
    <MemoryRouter>
      <NavBar />
    </MemoryRouter>
  )

  expect(container).toMatchSnapshot()
})
