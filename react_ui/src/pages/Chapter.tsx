import React from 'react'
import { useTranslation } from 'react-i18next'

import { ContentContainer } from '../components/ContentContainer'
import { useGetChapterBySlugQuery } from '../generated/graphql'
import { MainHeader } from '../components/MainHeader'
import { P } from '../components/P'
import { BackLink } from '../components/BackLink'
import { PreHeader } from '../components/PreHeader'
import { MainContent } from '../components/MainContent'
import { BorderBlock } from '../components/BorderBlock'
import { Background } from '../components/Background'

type Props = {
  slug: string
}

export const Chapter: React.FC<Props> = ({ slug }) => {
  const { t } = useTranslation()
  const { loading, data } = useGetChapterBySlugQuery({ variables: { slug } })

  if (loading) {
    return <div>Loading...</div>
  }

  if (!data?.groupBySlug) {
    return <div>Chapter {slug} not found</div>
  }

  const { groupBySlug: chapter } = data

  return (
    <MainContent>
      <Background />
      <ContentContainer>
        <div className="pb-32">
          <BackLink to="/chapters">{t('chapter.backLink')}</BackLink>
        </div>
        <PreHeader>California — USA</PreHeader>
        <MainHeader>{chapter.name}</MainHeader>
      </ContentContainer>

      <BorderBlock>
        <ContentContainer>
          <P>{chapter.description}</P>
          <P>slug: {chapter.slug}</P>
          <P>slack channel: {chapter.slackChannelName}</P>
          <P>request form: {chapter.requestForm}</P>
          <P>request form results: {chapter.requestFormResults}</P>
          <P>volunteer form: {chapter.volunteerForm}</P>
          <P>volunteer form results: {chapter.volunteerFormResults}</P>
          <P>donation form: {chapter.donationForm}</P>
          <P>donation form results: {chapter.donationFormResults}</P>
          <P>donation link: {chapter.donationLink}</P>
        </ContentContainer>
      </BorderBlock>
    </MainContent>
  )
}
