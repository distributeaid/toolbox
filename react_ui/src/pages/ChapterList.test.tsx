import { FetchResult } from '@apollo/client'
import { fireEvent, render, waitFor } from '@testing-library/react'
import { createMemoryHistory } from 'history'
import React, { Suspense } from 'react'
import { Router } from 'react-router-dom'

import {
  GetChapterListQuery,
  useGetChapterListQuery,
} from '../generated/graphql'
import { ChapterList } from './ChapterList'

jest.mock('../generated/graphql', () => ({
  useGetChapterListQuery: jest.fn(),
  useGetChapterQuery: jest.fn(),
}))

it('loads the chapter list', async () => {
  ;(useGetChapterListQuery as jest.Mock).mockReturnValueOnce({
    loading: false,
    data: {
      groups: [
        {
          id: '1',
          name: 'Seattle',
          slug: 'wa-sea',
          location: {
            province: 'WA',
            countryCode: 'US',
          },
        },
        {
          id: '2',
          name: 'Oakland',
          slug: 'ca-oak',
          location: {
            province: 'CA',
            conutryCode: 'US',
          },
        },
        {
          id: '3',
          name: 'Toronto',
          slug: 'on-toronto',
          location: {
            province: 'ON',
            countryCode: 'CA',
          },
        },
      ],
    } as FetchResult<GetChapterListQuery>,
  })

  const history = createMemoryHistory()
  const { findByText, getByText, container } = render(
    <Router history={history}>
      <Suspense fallback={null}>
        <ChapterList />
      </Suspense>
    </Router>
  )

  expect(await findByText('Seattle')).toBeVisible()
  expect(getByText('Oakland')).toBeVisible()

  expect(container).toMatchSnapshot()
  fireEvent.click(getByText('Oakland'))

  await waitFor(() =>
    expect(history.location).toMatchObject({ pathname: '/ca-oak' })
  )
})
