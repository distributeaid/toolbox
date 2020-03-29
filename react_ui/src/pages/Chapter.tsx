import React from "react";

type Country = {
  id: string;
  name: string;
};

type Chapter = {
  id: string;
  slug: string;
  name: string;
  country: Country;
  members: number;
};

type Maybe<T> = T | null

const useChapter = (slug: string): Maybe<Chapter> => {
  if (slug === 'seattle') {
    return {
      id: '1',
      slug: "seattle",
      name: "Seattle",
      members: 23,
      country: {
        id: "1",
        name: "US"
      }
    }
  }

  if (slug === 'oakland') {
    return {
      id: '2',
      slug: 'oakland',
      name: "Oakland",
      members: 45,
      country: {
        id: '2',
        name: "US"
      }
    }
  }

  return null
}

type Props = {
  slug: string;
};

export const Chapter: React.FC<Props> = ({ slug }) => {
  const chapter = useChapter(slug)

  if (!chapter) {
    return <div>Chapter <i>{slug}</i> not found</div>
  }

  return <div>{chapter.name}</div>;
};
