// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion
const themes = require('prism-react-renderer').themes;
const lightCodeTheme = themes.oneLight;
const darkCodeTheme = themes.oneDark;

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'solid_lints',
  tagline: 'An opinionated set of lint rules based on industry standards.',
  url: 'https://solid-software.github.io/',
  baseUrl: '/solid_lints/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.png',
  organizationName: 'solid_software',
  projectName: 'solid_lints',
  deploymentBranch: 'web-docs-deployment',
  trailingSlash: false,
  staticDirectories: ['static'],
   plugins: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      {
        hashed: true,
      },
    ],
  ],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl: 'https://github.com/solid-software/solid_lints/tree/master/doc/docusaurus',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      tableOfContents: {
        minHeadingLevel: 2,
        maxHeadingLevel: 6,
      },
      navbar: {
        title: 'solid_lints',
        logo: {
          alt: 'solid_lints Logo',
          src: 'img/favicon-xs.png',
        },
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/solid-software/solid_lints',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            label: 'Docs',
            to: '/docs/intro',
          },
          {
            label: 'GitHub',
            href: 'https://github.com/solid-software/solid_lints',
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Solid Software. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ['dart', 'yaml'],
      },
    }),
};

module.exports = config;
