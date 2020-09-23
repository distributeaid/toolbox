import React from 'react'

import { ChapterForm } from '../forms/ChapterForm'
import { Group, useGetChapterBySlugQuery } from '../generated/graphql'

type ChapterEditProps = {
  slug: string
}

export const ChapterEdit: React.FC<ChapterEditProps> = ({ slug }) => {
  const { loading, data } = useGetChapterBySlugQuery({ variables: { slug } })

  if (loading) {
    return <div>Loading...</div>
  }

  if (!data?.groupBySlug) {
    return <div>Chapter {slug} not found</div>
  }

  const { groupBySlug: chapter } = data

  return <ChapterForm editChapter={chapter as Group} />
}
