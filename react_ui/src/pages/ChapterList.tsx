import React from 'react'
import { Trans, useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

import { Background } from '../components/Background'
import { ContentContainer } from '../components/ContentContainer'
import { FAQFooter } from '../components/FAQFooter'
import { MainContent } from '../components/MainContent'
import { MainHeader } from '../components/MainHeader'
import { P } from '../components/P'
import { PreHeader } from '../components/PreHeader'
import { Group, useGetChapterListQuery } from '../generated/graphql'
import { countryCodeToName } from '../util/placeCodeToName'

export const ChapterItem: React.FC<{
  chapter: { name: string; slug: string; location: { province: string } }
}> = ({ chapter }) => {
  return (
    <li className="border border-collapse border-gray-200 bg-white font-heading hover:border-blue-500 hover:shadow-xl hover:relative hover:z-10 hover:border">
      <NavLink
        to={`/${chapter.slug}`}
        className="p-6 flex flex-row text-black text-sm">
        <div className="leading-5 font-semibold w-4/12">
          {chapter.location.province}
        </div>
        <div className="leading-5 font-medium w-6/12">{chapter.name}</div>
      </NavLink>
    </li>
  )
}

const ChaptersInCountry: React.FC<{
  t: (key: string) => string
  countryWithChapters: CountryWithChapters
}> = ({ countryWithChapters, t }) => {
  return (
    <div className="container p-4 md:mx-auto w-full max-w-4xl">
      <div className="grid grid-cols-1 gap-4">
        <h3 className="font-heading text-3xl font-semibold px-6 pb-6">
          {countryCodeToName(countryWithChapters.countryCode)}
        </h3>

        <div className="flex px-6 font-heading font-semibold text-lg text-blue-600">
          <div className="w-4/12 pb-0">{t('chapterList.provinceTerm')}</div>

          <div className="w-6/12 pb-0">{t('chapterList.chapterName')}</div>
        </div>

        <ul>
          {countryWithChapters.chapters.map(
            (g) => g && g.id && <ChapterItem key={g.id} chapter={g} />
          )}
        </ul>
      </div>

      <P className="text-center mt-8 mx-auto w-1/2">
        <Trans i18nKey="chapterList.cta">
          Don’t see your local chapter? Reach out to{' '}
          <a href="/request" className="underline text-blue-600">
            request supplies
          </a>
          ,{' '}
          <a href="/donate" className="underline text-blue-600">
            donate supplies
          </a>
          , or{' '}
          <a href="/volunteer" className="underline text-blue-600">
            volunteer
          </a>
          .
        </Trans>
      </P>
    </div>
  )
}

type CountryWithChapters = {
  countryCode: string
  chapters: Array<Group>
}

const groupChaptersByCountry = (
  chapters: Array<Group>
): Array<CountryWithChapters> => {
  const chaptersByCountry: { [country: string]: Array<Group> } = {}

  chapters.forEach((chapter: Group) => {
    if (chaptersByCountry[chapter.location.countryCode] == null) {
      chaptersByCountry[chapter.location.countryCode] = []
    }

    chaptersByCountry[chapter.location.countryCode].push(chapter)
  })

  const result: Array<CountryWithChapters> = []

  for (const countryCode in chaptersByCountry) {
    result.push({
      countryCode,
      chapters: chaptersByCountry[countryCode],
    })
  }

  result.sort((a: CountryWithChapters, b: CountryWithChapters) => {
    if (a.countryCode[0] > b.countryCode[0]) {
      return 1
    } else if (a.countryCode[0] < b.countryCode[0]) {
      return -1
    } else {
      return 0
    }
  })

  return result
}

export const ChapterList: React.FC = () => {
  const { t } = useTranslation()

  const { loading, error, data } = useGetChapterListQuery()

  if (loading || !data?.groups) {
    return null
  }

  if (error) {
    return <div>{error.toString()}</div>
  }

  const { groups: chapters } = data

  const chaptersByCountry = groupChaptersByCountry(chapters as Array<Group>)

  return (
    <MainContent>
      <Background />
      <ContentContainer>
        <div className="md:w-7/12 pt-16 sm:pt-32">
          <MainHeader>{t('chapterList.title')}</MainHeader>

          <PreHeader>
            <Trans i18nKey="chapterList.subtitle" />
          </PreHeader>
        </div>
      </ContentContainer>

      <div className="border-gray-400 border-t w-full bg-blue-50 mt-16 py-16">
        {chaptersByCountry.map((cwc) => (
          <ChaptersInCountry
            key={cwc.countryCode}
            t={t}
            countryWithChapters={cwc}
          />
        ))}

        <ContentContainer>
          <FAQFooter />
        </ContentContainer>
      </div>
    </MainContent>
  )
}
