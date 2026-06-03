FROM node:lts-alpine AS base

FROM base AS deps

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* pnpm-workspace.yaml* .npmrc* ./
RUN corepack use pnpm@latest && corepack enable &&  pnpm approve-builds --all && pnpm install --frozen-lockfile


FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .



RUN corepack use pnpm@latest && corepack enable pnpm && pnpm approve-builds --all && pnpm run build


FROM base AS runner
WORKDIR /app


ENV NODE_ENV=production



RUN addgroup -S -g 1001 nodejs  && adduser -S -G nodejs -u 1001 nextjs


COPY --from=builder /app/public ./public


COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static


USER nextjs

EXPOSE 3000

ENV PORT=3000

ENV HOSTNAME="0.0.0.0"

CMD [ "node", "server.js" ]