import React from 'react'

import { Group, Maybe } from '../generated/graphql'

const useChapter = (slug: string): Maybe<Group> => {
  if (slug === 'seattle') {
    return {
      id: '1',
      name: 'Seattle',
      description: 'The Seattle group',
    }
  }

  if (slug === 'oakland') {
    return {
      id: '2',
      name: 'Oakland',
      description: 'The Oakland group',
    }
  }

  return null
}

type Props = {
  slug: string
}

export const Chapter: React.FC<Props> = ({ slug }) => {
  const chapter = useChapter(slug)

  if (!chapter) {
    return (
      <div>
        Chapter <i>{slug}</i> not found
      </div>
    )
  }

  return <div>{chapter.name}</div>
}
