import { render } from '@testing-library/react'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'

import { Group, useGetChapterQuery } from '../generated/graphql'
import { Chapter } from './Chapter'

jest.mock('../generated/graphql', () => ({
  useGetChapterQuery: jest.fn(),
}))

it('loads the chapter details and renders the page', () => {
  ;(useGetChapterQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    data: {
      group: {
        id: '1',
        name: 'Oakland',
        slug: 'ca-oakland',
        description: 'the Oakland group',
        donationForm: 'donation form link',
        donationFormResults: 'donation form results link',
        donationLink: 'donation link',
        volunteerForm: 'volunteer form link',
        volunteerFormResults: 'volunteer form results link',
        slackChannelName: 'slack-channel-name',
        requestForm: 'request form link',
        requestFormResults: 'request form results link',
      } as Group,
    },
  })

  const { container, getByText } = render(
    <MemoryRouter>
      <Chapter slug="1" />
    </MemoryRouter>
  )
  expect(getByText('Oakland')).toBeVisible()
  expect(getByText('the Oakland group')).toBeVisible()
  expect(useGetChapterQuery).toHaveBeenCalledWith({ variables: { id: '1' } })

  expect(container).toMatchSnapshot()
})

it('shows an error message when chapter not found', () => {
  ;(useGetChapterQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    error: 'Whoops',
  })

  const { container, getByText } = render(<Chapter slug="1" />)
  expect(getByText('Chapter 1 not found')).toBeVisible()
  expect(useGetChapterQuery).toHaveBeenCalledWith({ variables: { id: '1' } })

  expect(container).toMatchSnapshot()
})

it('shows a loading message when loading', () => {
  ;(useGetChapterQuery as jest.Mock).mockReturnValueOnce({
    loading: true,
  })

  const { container, getByText } = render(<Chapter slug="1" />)
  expect(getByText('Loading...')).toBeVisible()

  expect(container).toMatchSnapshot()
})
