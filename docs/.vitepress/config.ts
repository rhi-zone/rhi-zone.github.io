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
              { text: 'Scribble', link: 'https://docs.rhi.zone/scribble/' },
              { text: 'defocus', link: 'https://docs.rhi.zone/defocus/' },
            ]},
            { text: 'Data Transformation', items: [
              { text: 'Tiltshift', link: 'https://docs.rhi.zone/tiltshift/' },
              { text: 'Paraphase', link: 'https://docs.rhi.zone/paraphase/' },
              { text: 'Concord', link: 'https://docs.rhi.zone/concord/' },
              { text: 'Reincarnate', link: 'https://docs.rhi.zone/reincarnate/' },
            ]},
            { text: 'Runtime & Interface', items: [
              { text: 'Rainbow', link: 'https://docs.rhi.zone/rainbow/' },
              { text: 'Moonlet', link: 'https://docs.rhi.zone/moonlet/' },
              { text: 'Crescent', link: 'https://docs.rhi.zone/crescent/' },
              { text: 'Dusklight', link: 'https://docs.rhi.zone/dusklight/' },
              { text: 'Deskspace', link: 'https://docs.rhi.zone/deskspace/' },
            ]},
            { text: 'Infrastructure', items: [
              { text: 'Myenv', link: 'https://docs.rhi.zone/myenv/' },
              { text: 'Portals', link: 'https://docs.rhi.zone/portals/' },
              { text: 'Zone', link: 'https://docs.rhi.zone/zone/' },
              { text: 'Server-Less', link: 'https://docs.rhi.zone/server-less/' },
              { text: 'Nanites', link: 'https://docs.rhi.zone/nanites/' },
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
            text: 'Claude Code',
            collapsed: true,
            items: [
              { text: 'Guide', link: '/claude-code-guide' },
              { text: 'Case Study', link: '/claude-code' },
            ]
          },
          {
            text: 'Concepts',
            collapsed: true,
            items: [
              { text: 'Affordance Opacity', link: '/affordance-opacity' },
              { text: 'Affordance Types', link: '/affordance-types' },
              { text: 'Affordance Surfaces', link: '/affordance-surfaces' },
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
              { text: 'Scribble', link: '/projects/scribble' },
              { text: 'defocus', link: '/projects/defocus' },
            ]
          },
          {
            text: 'Data Transformation',
            collapsed: true,
            items: [
              { text: 'Tiltshift', link: '/projects/tiltshift' },
              { text: 'Paraphase', link: '/projects/paraphase' },
              { text: 'Concord', link: '/projects/concord' },
              { text: 'Reincarnate', link: '/projects/reincarnate' },
            ]
          },
          {
            text: 'Runtime & Interface',
            collapsed: true,
            items: [
              { text: 'Rainbow', link: '/projects/rainbow' },
              { text: 'Moonlet', link: '/projects/moonlet' },
              { text: 'Crescent', link: '/projects/crescent' },
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
              { text: 'Nanites', link: '/projects/nanites' },
            ]
          },
          {
            text: 'Introspection',
            collapsed: true,
            items: [
              { text: 'Overview', link: '/introspection/' },
              { text: 'Session Analysis', link: '/introspection/session-analysis' },
              { text: 'Session Deep Dives', link: '/introspection/session-deep-dives' },
              { text: 'Activity Log', collapsed: true, items: [
                { text: 'Dec 15–21', link: '/introspection/log/2025-12-21' },
                { text: 'Dec 22–28', link: '/introspection/log/2025-12-28' },
                { text: 'Dec 29–Jan 4', link: '/introspection/log/2026-01-04' },
                { text: 'Jan 5–11', link: '/introspection/log/2026-01-11' },
                { text: 'Jan 12–18', link: '/introspection/log/2026-01-18' },
                { text: 'Jan 19–25', link: '/introspection/log/2026-01-25' },
                { text: 'Jan 26–Feb 1', link: '/introspection/log/2026-02-01' },
                { text: 'Feb 2–8', link: '/introspection/log/2026-02-08' },
                { text: 'Feb 9–15', link: '/introspection/log/2026-02-15' },
                { text: 'Feb 16–22', link: '/introspection/log/2026-02-22' },
                { text: 'Feb 23–26', link: '/introspection/log/2026-02-25' },
              ]},
              { text: 'Daily Logs', collapsed: true, items: [
                { text: 'Friction Analysis: Mar 29', link: '/introspection/log/friction-analysis-2026-03-29' },
                { text: 'Sequence Analysis: Mar 29', link: '/introspection/log/sequence-analysis-2026-03-29' },
                { text: 'Synthesis: Apr 1–20', link: '/introspection/log/synthesis-2026-04-01-2026-04-20' },
                { text: 'Synthesis: Mar 28–31', link: '/introspection/log/synthesis-2026-03-28-2026-03-31' },
                { text: 'Synthesis: Mar 20–27', link: '/introspection/log/synthesis-2026-03-20-2026-03-27' },
                { text: 'Synthesis: Mar 17–19', link: '/introspection/log/synthesis-mar17-mar19' },
                { text: 'Synthesis: Mar 10–16', link: '/introspection/log/synthesis-mar10-mar16' },
                { text: 'Synthesis: Mar 5–9', link: '/introspection/log/synthesis-mar5-mar9' },
                { text: 'Synthesis: Jan 28–Mar 4', link: '/introspection/log/synthesis-jan28-mar4' },
                { text: 'Synthesis: Jan 28–Mar 2', link: '/introspection/log/synthesis-jan28-mar2' },
                { text: 'Jan 28', link: '/introspection/log/daily/2026-01-28' },
                { text: 'Jan 29', link: '/introspection/log/daily/2026-01-29' },
                { text: 'Jan 30', link: '/introspection/log/daily/2026-01-30' },
                { text: 'Jan 31', link: '/introspection/log/daily/2026-01-31' },
                { text: 'Feb 1', link: '/introspection/log/daily/2026-02-01' },
                { text: 'Feb 2', link: '/introspection/log/daily/2026-02-02' },
                { text: 'Feb 3', link: '/introspection/log/daily/2026-02-03' },
                { text: 'Feb 4', link: '/introspection/log/daily/2026-02-04' },
                { text: 'Feb 5', link: '/introspection/log/daily/2026-02-05' },
                { text: 'Feb 6', link: '/introspection/log/daily/2026-02-06' },
                { text: 'Feb 7', link: '/introspection/log/daily/2026-02-07' },
                { text: 'Feb 8', link: '/introspection/log/daily/2026-02-08' },
                { text: 'Feb 9', link: '/introspection/log/daily/2026-02-09' },
                { text: 'Feb 10', link: '/introspection/log/daily/2026-02-10' },
                { text: 'Feb 11', link: '/introspection/log/daily/2026-02-11' },
                { text: 'Feb 12', link: '/introspection/log/daily/2026-02-12' },
                { text: 'Feb 13', link: '/introspection/log/daily/2026-02-13' },
                { text: 'Feb 14', link: '/introspection/log/daily/2026-02-14' },
                { text: 'Feb 15', link: '/introspection/log/daily/2026-02-15' },
                { text: 'Feb 16', link: '/introspection/log/daily/2026-02-16' },
                { text: 'Feb 17', link: '/introspection/log/daily/2026-02-17' },
                { text: 'Feb 18', link: '/introspection/log/daily/2026-02-18' },
                { text: 'Feb 19', link: '/introspection/log/daily/2026-02-19' },
                { text: 'Feb 20', link: '/introspection/log/daily/2026-02-20' },
                { text: 'Feb 21', link: '/introspection/log/daily/2026-02-21' },
                { text: 'Feb 22', link: '/introspection/log/daily/2026-02-22' },
                { text: 'Feb 23', link: '/introspection/log/daily/2026-02-23' },
                { text: 'Feb 24', link: '/introspection/log/daily/2026-02-24' },
                { text: 'Feb 25', link: '/introspection/log/daily/2026-02-25' },
                { text: 'Feb 26', link: '/introspection/log/daily/2026-02-26' },
                { text: 'Feb 27', link: '/introspection/log/daily/2026-02-27' },
                { text: 'Feb 28', link: '/introspection/log/daily/2026-02-28' },
                { text: 'Mar 1', link: '/introspection/log/daily/2026-03-01' },
                { text: 'Mar 2', link: '/introspection/log/daily/2026-03-02' },
                { text: 'Mar 3', link: '/introspection/log/daily/2026-03-03' },
                { text: 'Mar 4', link: '/introspection/log/daily/2026-03-04' },
                { text: 'Mar 5', link: '/introspection/log/daily/2026-03-05' },
                { text: 'Mar 6', link: '/introspection/log/daily/2026-03-06' },
                { text: 'Mar 7', link: '/introspection/log/daily/2026-03-07' },
                { text: 'Mar 8', link: '/introspection/log/daily/2026-03-08' },
                { text: 'Mar 9', link: '/introspection/log/daily/2026-03-09' },
                { text: 'Mar 10', link: '/introspection/log/daily/2026-03-10' },
                { text: 'Mar 11', link: '/introspection/log/daily/2026-03-11' },
                { text: 'Mar 12', link: '/introspection/log/daily/2026-03-12' },
                { text: 'Mar 13', link: '/introspection/log/daily/2026-03-13' },
                { text: 'Mar 14', link: '/introspection/log/daily/2026-03-14' },
                { text: 'Mar 15', link: '/introspection/log/daily/2026-03-15' },
                { text: 'Mar 16', link: '/introspection/log/daily/2026-03-16' },
                { text: 'Mar 17', link: '/introspection/log/daily/2026-03-17' },
                { text: 'Mar 18', link: '/introspection/log/daily/2026-03-18' },
                { text: 'Mar 19', link: '/introspection/log/daily/2026-03-19' },
                { text: 'Mar 20', link: '/introspection/log/daily/2026-03-20' },
                { text: 'Mar 21', link: '/introspection/log/daily/2026-03-21' },
                { text: 'Mar 22', link: '/introspection/log/daily/2026-03-22' },
                { text: 'Mar 23', link: '/introspection/log/daily/2026-03-23' },
                { text: 'Mar 24', link: '/introspection/log/daily/2026-03-24' },
                { text: 'Mar 25', link: '/introspection/log/daily/2026-03-25' },
                { text: 'Mar 26', link: '/introspection/log/daily/2026-03-26' },
                { text: 'Mar 27', link: '/introspection/log/daily/2026-03-27' },
                { text: 'Mar 28', link: '/introspection/log/daily/2026-03-28' },
                { text: 'Mar 29', link: '/introspection/log/daily/2026-03-29' },
                { text: 'Mar 30', link: '/introspection/log/daily/2026-03-30' },
                { text: 'Mar 31', link: '/introspection/log/daily/2026-03-31' },
                { text: 'Apr 1', link: '/introspection/log/daily/2026-04-01' },
                { text: 'Apr 2', link: '/introspection/log/daily/2026-04-02' },
                { text: 'Apr 3', link: '/introspection/log/daily/2026-04-03' },
                { text: 'Apr 4', link: '/introspection/log/daily/2026-04-04' },
                { text: 'Apr 5', link: '/introspection/log/daily/2026-04-05' },
                { text: 'Apr 6', link: '/introspection/log/daily/2026-04-06' },
                { text: 'Apr 7', link: '/introspection/log/daily/2026-04-07' },
                { text: 'Apr 8', link: '/introspection/log/daily/2026-04-08' },
                { text: 'Apr 9', link: '/introspection/log/daily/2026-04-09' },
                { text: 'Apr 10', link: '/introspection/log/daily/2026-04-10' },
                { text: 'Apr 11', link: '/introspection/log/daily/2026-04-11' },
                { text: 'Apr 12', link: '/introspection/log/daily/2026-04-12' },
                { text: 'Apr 13', link: '/introspection/log/daily/2026-04-13' },
                { text: 'Apr 14', link: '/introspection/log/daily/2026-04-14' },
                { text: 'Apr 15', link: '/introspection/log/daily/2026-04-15' },
                { text: 'Apr 16', link: '/introspection/log/daily/2026-04-16' },
                { text: 'Apr 17', link: '/introspection/log/daily/2026-04-17' },
                { text: 'Apr 18', link: '/introspection/log/daily/2026-04-18' },
                { text: 'Apr 19', link: '/introspection/log/daily/2026-04-19' },
                { text: 'Apr 20', link: '/introspection/log/daily/2026-04-20' },
              ]},
            ]
          },
          {
            text: 'Archive',
            collapsed: true,
            items: [
              { text: 'Rainbow Commands', link: '/rainbow-commands' },
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
