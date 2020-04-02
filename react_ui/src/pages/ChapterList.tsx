import { useQuery } from '@apollo/react-hooks'
import gql from 'graphql-tag'
import React from 'react'
import { Trans, useTranslation } from 'react-i18next'

import { ContentContainer } from '../components/ContentContainer'
import { TextLink } from '../components/TextLink'

type Country = {
  id: string
  code: string
  name: string
}

type ChapterLocation = {
  country: Country
  province: string
}

type Group = {
  id: string
  name: string
  description: string
}

type GroupsQuery = {
  groups: Group[]
}

export const ChapterItem: React.FC<{ chapter: Group }> = ({ chapter }) => {
  return (
    <li className="border-t border-gray-200">
      <a href={`/${chapter.id}`} className="">
        <div className="py-4 hover:bg-gray-200">
          <div className="flex items-center justify-between">
            <div className="text-sm leading-5 font-medium text-black">
              {chapter.name}
            </div>

            <div className="ml-2 flex-shrink-0 flex">
              <span className="px-2 inline-flex text-xs leading-5 font-semibold">
                {/* {chapter.location.province}, {chapter.location.country.name} */}
              </span>
            </div>
          </div>
        </div>
      </a>
    </li>
  )
}

export const ChapterList: React.FC = () => {
  const { t } = useTranslation()

  const { loading, error, data } = useQuery<GroupsQuery>(gql`
    query {
      groups {
        id
        description
        name
      }
    }
  `)

  if (loading || !data) {
    return null
  }

  if (error) {
    return <div>{error.toString()}</div>
  }

  const { groups: chapters } = data

  return (
    <ContentContainer>
      <div className="p-4 md:p-8">
        <div className="mb-4 md:mb-8">
          <h1 className="font-bold text-xl">{t("chapterList.title")}</h1>

          <p className="py-4">
            {t("chapterList.subtitle")}
          </p>

          <p>
            <Trans i18nKey="chapterList.instructions">
              If your area doesn't have a Masks For Docs Chapter yet, we are
              looking for volunteers to start new ones. Get in touch on{' '}
              <TextLink href="https://masksfordocs.slack.com">Slack</TextLink>
              to start one [Need better copy here].
            </Trans>
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4">
          <ul>
            {chapters.map((g, i) => (
              <ChapterItem key={g.id} chapter={g} />
            ))}
          </ul>
        </div>
      </div>
    </ContentContainer>
  )
}
