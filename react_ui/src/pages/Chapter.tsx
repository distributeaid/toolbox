import React from 'react'

import { ContentContainer } from '../components/ContentContainer'
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
    return <div>Chapter {slug} not found</div>
  }

  const { group: chapter } = data

  return (
    <ContentContainer>
      <div className="p-4 md:p-8">
        <div className="mb-4 md:mb-8">
          <h1 className="font-bold text-xl">{chapter.name}</h1>

          <p className="py-4">{chapter.description}</p>
        </div>
      </div>
    </ContentContainer>
  )
}
