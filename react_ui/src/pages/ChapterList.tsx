import React from "react";

import {ContentContainer} from "../components/ContentContainer";

type Country = {
  id: string
  name: string
}

type Chapter = {
  id: string
  slug: string
  name: string
  country: Country
  members: number
}

const useStubChapterList = (): { chapters: Chapter[] } => {
  return {
    chapters: [
      {
        id: '1',
        slug: 'seattle',
        name: "Seattle",
        members: 23,
        country: {
          id: '1',
          name: "US"
        }
      },
      {
        id: '2',
        slug: 'oakland',
        name: "Oakland",
        members: 45,
        country: {
          id: '2',
          name: "US"
        }
      }
    ]
  };
};

export const ChapterItem: React.FC<{ chapter: Chapter }> = ({ chapter }) => {
  return (
    <li>
      <a
        href={`/${chapter.slug}`}
        className=""
      >
        <div className="px-4 py-4 sm:px-6">
          <div className="flex items-center justify-between">
            <div className="text-sm leading-5 font-medium text-indigo-600 truncate">
              {chapter.name}
            </div>
            <div className="ml-2 flex-shrink-0 flex">
              <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                {chapter.country.name}
              </span>
            </div>
          </div>
          <div className="mt-2 sm:flex sm:justify-between">
            <div className="sm:flex">
              <div className="mr-6 flex items-center text-sm leading-5 text-gray-500">
                {chapter.members}
              </div>
            </div>
            <div className="mt-2 flex items-center text-sm leading-5 text-gray-500 sm:mt-0">
            </div>
          </div>
        </div>
      </a>
    </li>
  );
};

export const ChapterList: React.FC = () => {
  const { chapters } = useStubChapterList();

  return (
    <ContentContainer>
      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <ul>{chapters.map((g, i) => <ChapterItem key={g.id} chapter={g} />)}</ul>
      </div>
    </ContentContainer>
  );
};
