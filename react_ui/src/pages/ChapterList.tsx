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
import US_STATES from '../data/us_states.json'
import { Group, Maybe, useGetChapterListQuery } from '../generated/graphql'
import { countryCodeToName } from '../util/placeCodeToName'

const provinceLongName = ({
  province,
  countryCode,
}: {
  province: string
  countryCode: string
}) => {
  if (countryCode === 'US') {
    return US_STATES.find(({ code }) => code === province)?.name ?? province
  }

  return province
}

const provinceLocalName = (countryCode: string): string => {
  switch (countryCode) {
    case 'CA':
      return 'Province'
    default:
      return 'State'
  }
}

export const ChapterItem: React.FC<{
  chapter: {
    name: string
    slug: string
    location: { province: string; countryCode: string }
  }
}> = ({ chapter }) => (
  <li className="border border-collapse border-gray-200 bg-white font-heading fill-black hover:border-blue-500 hover:shadow-xl hover:relative hover:z-10 hover:border hover:fill-pink">
    <NavLink
      to={`/${chapter.slug}`}
      className="p-6 flex flex-row text-black text-sm">
      <div className="leading-5 font-semibold w-4/12">
        {provinceLongName(chapter.location)}
      </div>
      <div className="leading-5 font-medium w-4/12">{chapter.name}</div>
      <div className="leading-5 w-4/12 flex justify-end">
        <svg
          width="17"
          height="17"
          viewBox="0 0 17 17"
          fill="none"
          xmlns="http://www.w3.org/2000/svg">
          <g clipPath="url(#clip0)">
            <path d="M1.82846 7.4855V9.4852L10.6065 9.4852L10.6065 13.4351L15.5562 8.48535L10.6065 3.5356L10.6065 7.4855L1.82846 7.4855Z" />
          </g>
          <defs>
            <clipPath id="clip0">
              <rect
                y="8.48535"
                width="12"
                height="12"
                transform="rotate(-45 0 8.48535)"
                fill="white"
              />
            </clipPath>
          </defs>
        </svg>
      </div>
    </NavLink>
  </li>
)

const ChaptersInCountry: React.FC<{
  t: (key: string) => string
  countryWithChapters: CountryWithChapters
}> = ({ countryWithChapters, t }) => (
  <div className="container p-6 pb-12 last:pb-6 md:mx-auto w-full max-w-4xl">
    <div className="grid grid-cols-1 gap-2">
      <h3 className="font-heading text-3xl font-semibold px-6">
        {countryCodeToName(countryWithChapters.countryCode)}
      </h3>

      <div className="flex px-6 font-heading font-semibold text-lg text-blue-600">
        <div className="w-4/12 pb-0">
          {provinceLocalName(countryWithChapters.countryCode)}
        </div>

        <div className="w-6/12 pb-0">{t('chapterList.chapterName')}</div>
      </div>

      <ul>
        {countryWithChapters.chapters.map((g) => (
          <ChapterItem key={g.id} chapter={g} />
        ))}
      </ul>
    </div>

    <P className="text-center mx-auto pt-6 w-2/3 sm:w-1/2">
      <Trans i18nKey="chapterList.cta">
        Don’t see your local chapter? Reach out to{' '}
        <a
          href="https://share.hsforms.com/1ZEAK2ikxSFKqR_XR7J-x5Q4dh7j"
          className="underline text-blue-600"
          target="_blank"
          rel="noopener noreferrer">
          request supplies
        </a>
        ,{' '}
        <a
          href="https://share.hsforms.com/19adMT7wKRNSvxJSYJHOdGw4dh7j"
          className="underline text-blue-600"
          target="_blank"
          rel="noopener noreferrer">
          donate supplies
        </a>
        , or{' '}
        <a
          href="https://share.hsforms.com/1wEiqrs4DTQGBBQ9z2wBg8Q4dh7j"
          className="underline text-blue-600"
          target="_blank"
          rel="noopener noreferrer">
          volunteer
        </a>
        .
      </Trans>
    </P>
  </div>
)

type CountryWithChapters = {
  countryCode: string
  chapters: Group[]
}

const groupChaptersByCountry = (chapters: Group[]): CountryWithChapters[] => {
  const chaptersByCountry: { [country: string]: Group[] } = {}

  for (const chapter of chapters) {
    const { countryCode } = chapter.location
    if (!chaptersByCountry[countryCode]) {
      chaptersByCountry[countryCode] = []
    }

    chaptersByCountry[countryCode].push(chapter)
  }

  return Object.keys(chaptersByCountry)
    .map((countryCode) => ({
      countryCode,
      chapters: chaptersByCountry[countryCode].sort((a, b) =>
        a.location.province
          .toLowerCase()
          .localeCompare(b.location.province.toLowerCase())
      ),
    }))
    .sort((a, b) =>
      a.countryCode.toLowerCase().localeCompare(b.countryCode.toLowerCase())
    )
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

  const chaptersByCountry = groupChaptersByCountry(
    (chapters as Maybe<Group>[]).filter(
      (chapter): chapter is Group => !!chapter
    )
  )

  return (
    <MainContent>
      <Background />
      <ContentContainer>
        <div className="md:w-7/12 pt-16 sm:pt-32">
          <MainHeader>{t('chapterList.title')}</MainHeader>

          <PreHeader>
            <Trans i18nKey="chapterList.subtitle">
              Connect locally to get what you need and give what you can. Find
              your local chapter below to{' '}
              <strong className="font-semibold">request supplies</strong>,{' '}
              <strong className="font-semibold">donate supplies</strong>, or{' '}
              <strong className="font-semibold">volunteer</strong>
            </Trans>
          </PreHeader>
        </div>
      </ContentContainer>

      <div className="border-gray-400 border-t w-full bg-lightBlue mt-16 py-16">
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
