import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(
  defineConfig({
    title: 'rhi',
    description: 'A glue layer for computers',

    themeConfig: {
      nav: [
        { text: 'Home', link: '/' },
        { text: 'About', link: '/about' },
        { text: 'Projects', link: '/projects/' },
        {
          text: 'Docs',
          items: [
            { text: 'Code Intelligence', items: [
              { text: 'Normalize', link: 'https://docs.rhi.zone/normalize/' },
              { text: 'Gels', link: 'https://docs.rhi.zone/gels/' },
              { text: 'Motif', link: 'https://docs.rhi.zone/motif/' },
            ]},
            { text: 'Generation', items: [
              { text: 'Unshape', link: 'https://docs.rhi.zone/unshape/' },
              { text: 'Wick', link: 'https://docs.rhi.zone/wick/' },
            ]},
            { text: 'Games & Worlds', items: [
              { text: 'Playmate', link: 'https://docs.rhi.zone/playmate/' },
              { text: 'Interconnect', link: 'https://docs.rhi.zone/interconnect/' },
            ]},
            { text: 'Data Transformation', items: [
              { text: 'Paraphase', link: 'https://docs.rhi.zone/paraphase/' },
              { text: 'Concord', link: 'https://docs.rhi.zone/concord/' },
              { text: 'Reincarnate', link: 'https://docs.rhi.zone/reincarnate/' },
            ]},
            { text: 'Runtime & Interface', items: [
              { text: 'Moonlet', link: 'https://docs.rhi.zone/moonlet/' },
              { text: 'Dusklight', link: 'https://docs.rhi.zone/dusklight/' },
              { text: 'Deskspace', link: 'https://docs.rhi.zone/deskspace/' },
            ]},
            { text: 'Infrastructure', items: [
              { text: 'Myenv', link: 'https://docs.rhi.zone/myenv/' },
              { text: 'Portals', link: 'https://docs.rhi.zone/portals/' },
              { text: 'Zone', link: 'https://docs.rhi.zone/zone/' },
              { text: 'Server-Less', link: 'https://docs.rhi.zone/server-less/' },
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
              { text: 'Why Software Is Hard', link: '/why-software-is-hard' },
              { text: 'Interaction Graph', link: '/interaction-graph' },
              { text: 'Collaboration', link: '/collaboration' },
              { text: 'Use Cases', link: '/use-cases' },
              { text: 'Architecture', link: '/architecture' },
              { text: 'Integration', link: '/integration' },
            ]
          },
          {
            text: 'Concepts',
            collapsed: true,
            items: [
              { text: 'Affordance Opacity', link: '/affordance-opacity' },
              { text: 'Explorations', link: '/explorations' },
              { text: 'Prior Art', link: '/prior-art' },
            ]
          },
          {
            text: 'Code Intelligence',
            collapsed: true,
            items: [
              { text: 'Normalize', link: '/projects/normalize' },
              { text: 'Gels', link: '/projects/gels' },
              { text: 'Motif', link: '/projects/motif' },
            ]
          },
          {
            text: 'Generation',
            collapsed: true,
            items: [
              { text: 'Unshape', link: '/projects/unshape' },
              { text: 'Wick', link: '/projects/wick' },
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
              { text: 'Reincarnate', link: '/projects/reincarnate' },
            ]
          },
          {
            text: 'Runtime & Interface',
            collapsed: true,
            items: [
              { text: 'Moonlet', link: '/projects/moonlet' },
              { text: 'Dusklight', link: '/projects/dusklight' },
              { text: 'Deskspace', link: '/projects/deskspace' },
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
            text: 'Introspection',
            collapsed: true,
            items: [
              { text: 'Overview', link: '/introspection/' },
              { text: 'Session Analysis', link: '/introspection/session-analysis' },
              { text: 'Session Deep Dives', link: '/introspection/session-deep-dives' },
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
