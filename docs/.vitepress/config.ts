import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(
  defineConfig({
    title: 'rhi',
    description: 'Tools for programmable creativity',

    themeConfig: {
      nav: [
        { text: 'Home', link: '/' },
        { text: 'About', link: '/about' },
        { text: 'Projects', link: '/projects/' },
        {
          text: 'Docs',
          items: [
            { text: 'Code Intelligence', items: [
              { text: 'Normalize', link: 'https://rhi.zone/normalize/' },
            ]},
            { text: 'Generation', items: [
              { text: 'Unshape', link: 'https://rhi.zone/unshape/' },
              { text: 'Dew', link: 'https://rhi.zone/dew/' },
            ]},
            { text: 'Games & Worlds', items: [
              { text: 'Playmate', link: 'https://rhi.zone/playmate/' },
              { text: 'Interconnect', link: 'https://rhi.zone/interconnect/' },
            ]},
            { text: 'Data Transformation', items: [
              { text: 'Paraphase', link: 'https://rhi.zone/paraphase/' },
              { text: 'Concord', link: 'https://rhi.zone/concord/' },
              { text: 'Resurrect', link: 'https://rhi.zone/resurrect/' },
            ]},
            { text: 'Runtime & Interface', items: [
              { text: 'Moonlet', link: 'https://rhi.zone/moonlet/' },
              { text: 'Dusklight', link: 'https://rhi.zone/dusklight/' },
            ]},
            { text: 'Infrastructure', items: [
              { text: 'Myenv', link: 'https://rhi.zone/myenv/' },
              { text: 'Portals', link: 'https://rhi.zone/portals/' },
              { text: 'Zone', link: 'https://rhi.zone/zone/' },
              { text: 'Server-Less', link: 'https://rhi.zone/server-less/' },
            ]},
          ]
        },
      ],

      sidebar: {
        '/': [
          {
            text: 'Overview',
            items: [
              { text: 'About', link: '/about' },
              { text: 'Vision', link: '/vision' },
              { text: 'Problems', link: '/problems' },
              { text: 'Collaboration', link: '/collaboration' },
              { text: 'Use Cases', link: '/use-cases' },
              { text: 'Architecture', link: '/architecture' },
              { text: 'Integration', link: '/integration' },
            ]
          },
          {
            text: 'Code Intelligence',
            collapsed: true,
            items: [
              { text: 'Normalize', link: '/projects/normalize' },
            ]
          },
          {
            text: 'Generation',
            collapsed: true,
            items: [
              { text: 'Unshape', link: '/projects/unshape' },
              { text: 'Dew', link: '/projects/dew' },
            ]
          },
          {
            text: 'Games & Worlds',
            collapsed: true,
            items: [
              { text: 'Playmate', link: '/projects/playmate' },
              { text: 'Interconnect', link: '/projects/interconnect' },
            ]
          },
          {
            text: 'Data Transformation',
            collapsed: true,
            items: [
              { text: 'Paraphase', link: '/projects/paraphase' },
              { text: 'Concord', link: '/projects/concord' },
              { text: 'Resurrect', link: '/projects/resurrect' },
            ]
          },
          {
            text: 'Runtime & Interface',
            collapsed: true,
            items: [
              { text: 'Moonlet', link: '/projects/moonlet' },
              { text: 'Dusklight', link: '/projects/dusklight' },
            ]
          },
          {
            text: 'Infrastructure',
            collapsed: true,
            items: [
              { text: 'Myenv', link: '/projects/myenv' },
              { text: 'Portals', link: '/projects/portals' },
              { text: 'Zone', link: '/projects/zone' },
              { text: 'Server-Less', link: '/projects/server-less' },
            ]
          },
          {
            text: 'Community',
            items: [
              { text: 'Contributing', link: '/contributing' },
            ]
          },
        ]
      },

      socialLinks: [
        { icon: 'github', link: 'https://github.com/rhi-zone' }
      ],

      search: {
        provider: 'local'
      },
    },

    vite: {
      optimizeDeps: {
        include: ['mermaid'],
      },
    },
  }),
)
