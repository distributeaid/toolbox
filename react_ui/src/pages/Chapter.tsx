import React from 'react'

import { ContentContainer } from '../components/ContentContainer'
import { useGetChapterQuery } from '../generated/graphql'
import { NavLink } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

type Props = {
  slug: string
}

export const Chapter: React.FC<Props> = ({ slug }) => {
  const { t } = useTranslation()
  const { loading, data } = useGetChapterQuery({ variables: { id: slug } })

  if (loading) {
    return <div>Loading...</div>
  }

  if (!data?.group) {
    return <div>Chapter {slug} not found</div>
  }

  const { group: chapter } = data

  return (
    <>
      <NavLink to="/chapters">{t('chapter.backLink')}</NavLink>
      <ContentContainer>
        <div className="p-4 md:p-8">
          <div className="mb-4 md:mb-8">
            <h1 className="font-bold text-xl">{chapter.name}</h1>

            <p className="py-4">{chapter.description}</p>
          </div>
        </div>
      </ContentContainer>
    </>
  )
}
