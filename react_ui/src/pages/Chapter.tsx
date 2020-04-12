import React from 'react'
import { useTranslation } from 'react-i18next'

import { Background } from '../components/Background'
import { BackLink } from '../components/BackLink'
import { BorderBlock } from '../components/BorderBlock'
import { ContentContainer } from '../components/ContentContainer'
import { MainContent } from '../components/MainContent'
import { MainHeader } from '../components/MainHeader'
import { P } from '../components/P'
import { PreHeader } from '../components/PreHeader'
import { ShadowButtonLink } from '../components/ShadowButtonLink'
import { Maybe, useGetChapterBySlugQuery } from '../generated/graphql'

type Props = {
  slug: string
}

const splitIntoParagraphs = (text: Maybe<string>) =>
  text
    ?.split(/\n+/)
    .filter((x) => x.length > 0)
    .map((line) => <P key={line}>{line}</P>)

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
        <div className="pb-16 sm:pb-32">
          <BackLink to="/chapters">{t('chapter.backLink')}</BackLink>
        </div>
        <PreHeader>California — USA</PreHeader>
        <MainHeader>{chapter.name}</MainHeader>
      </ContentContainer>

      <BorderBlock>
        <ContentContainer>
          <div className="sm:flex py-6 sm:py-12">
            <div className="sm:w-7/12 pb-6" data-testid="description">
              {splitIntoParagraphs(chapter.description)}
            </div>
            <div className="sm:w-5/12 sm:pr-2">
              {chapter.requestForm && (
                <ShadowButtonLink
                  className="bg-blue-600 w-full mb-8"
                  to={chapter.requestForm}>
                  Request Supplies
                </ShadowButtonLink>
              )}
              {chapter.donationForm && (
                <ShadowButtonLink
                  className="bg-red-600 w-full mb-8"
                  to={chapter.donationForm}>
                  Donate Supplies
                </ShadowButtonLink>
              )}
              {chapter.volunteerForm && (
                <ShadowButtonLink
                  className="bg-purple-600 w-full"
                  to={chapter.volunteerForm}>
                  Volunteer
                </ShadowButtonLink>
              )}
            </div>
          </div>
        </ContentContainer>
      </BorderBlock>

      <ContentContainer>
        <div className="flex flex-col justify-center py-10 sm:py-20">
          <h2 className="text-center font-heading font-semibold text-2xl sm:text-5xl leading-loose mb-4">
            Have a question?
          </h2>
          <ShadowButtonLink className="bg-blue-600 sm:w-auto" to="/faq">
            Check Out Our FAQs
          </ShadowButtonLink>
        </div>
      </ContentContainer>
    </MainContent>
  )
}
