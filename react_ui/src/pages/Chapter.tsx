import React from 'react'

import { useGetChapterQuery } from '../generated/graphql'

type Props = {
  slug: string
}

export const Chapter: React.FC<Props> = ({ slug }) => {
  const { loading, data } = useGetChapterQuery({ variables: { id: slug } })

  if (loading) {
    return <div>Loading...</div>
  }

  if (!data?.group) {
    return (
      <div>
        Chapter <i>{slug}</i> not found
      </div>
    )
  }

  const { group: chapter } = data

  return <div>Found chapter: {chapter.id}</div>
}
