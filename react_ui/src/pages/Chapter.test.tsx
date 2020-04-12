import { render } from '@testing-library/react'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'

import { Group, useGetChapterBySlugQuery } from '../generated/graphql'
import { Chapter } from './Chapter'

jest.mock('../generated/graphql', () => ({
  useGetChapterBySlugQuery: jest.fn(),
}))

const renderUI = (slug: string) =>
  render(
    <MemoryRouter>
      <Chapter slug={slug} />
    </MemoryRouter>
  )

it('loads the chapter details and renders the page', () => {
  ;(useGetChapterBySlugQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    data: {
      groupBySlug: {
        id: '1',
        slug: 'oakland',
        name: 'Oakland',
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

  const { container, getByText } = renderUI('oakland')
  expect(getByText('Oakland')).toBeVisible()
  expect(getByText('the Oakland group')).toBeVisible()
  expect(useGetChapterBySlugQuery).toHaveBeenCalledWith({
    variables: { slug: 'oakland' },
  })

  expect(container).toMatchSnapshot()
})

it('shows an error message when chapter not found', () => {
  ;(useGetChapterBySlugQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    error: 'Whoops',
  })

  const { container, getByText } = renderUI('1')
  expect(getByText('Chapter "1" not found')).toBeVisible()
  expect(useGetChapterBySlugQuery).toHaveBeenCalledWith({
    variables: { slug: 'oakland' },
  })

  expect(container).toMatchSnapshot()
})

it('shows a loading message when loading', () => {
  ;(useGetChapterBySlugQuery as jest.Mock).mockReturnValueOnce({
    loading: true,
  })

  const { container, getByText } = renderUI('oakland')
  expect(getByText('Loading...')).toBeVisible()

  expect(container).toMatchSnapshot()
})
