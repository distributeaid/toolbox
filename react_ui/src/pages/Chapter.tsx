import React from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

import { ContentContainer } from '../components/ContentContainer'
import { useGetChapterQuery } from '../generated/graphql'

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
            <p className="py-4">slug: {chapter.slug}</p>
            <p className="py-4">slack channel: {chapter.slackChannelName}</p>
            <p className="py-4">request form: {chapter.requestForm}</p>
            <p className="py-4">
              request form results: {chapter.requestFormResults}
            </p>
            <p className="py-4">volunteer form: {chapter.volunteerForm}</p>
            <p className="py-4">
              volunteer form results: {chapter.volunteerFormResults}
            </p>
            <p className="py-4">donation form: {chapter.donationForm}</p>
            <p className="py-4">
              donation form results: {chapter.donationFormResults}
            </p>
            <p className="py-4">donation link: {chapter.donationLink}</p>
          </div>
        </div>
      </ContentContainer>
    </>
  )
}
