import React from 'react'
import { Chapter } from './Chapter'
import { render } from '@testing-library/react'
import { useGetChapterQuery } from '../generated/graphql'

jest.mock('../generated/graphql', () => ({
  useGetChapterQuery: jest.fn(),
}))

it('loads the chapter details and renders the page', () => {
  ;(useGetChapterQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    data: {
      group: {
        id: '1',
      },
    },
  })

  const { container, getByText } = render(<Chapter slug="1" />)
  expect(getByText('Found chapter: 1')).toBeVisible()
  expect(useGetChapterQuery).toHaveBeenCalledWith({ variables: { id: '1' }})

  expect(container).toMatchSnapshot()
})

it('shows an error message when chapter not found', () => {
  ;(useGetChapterQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    error: 'Whoops',
  })

  const { container, getByText } = render(<Chapter slug="1" />)
  expect(getByText('Chapter 1 not found')).toBeVisible()
  expect(useGetChapterQuery).toHaveBeenCalledWith({ variables: { id: '1' }})

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