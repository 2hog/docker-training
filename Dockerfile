FROM jekyll/jekyll:3.8 as dev
WORKDIR /srv/jekyll/
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM dev as builder
COPY ./ ./
RUN jekyll build

FROM nginx:alpine
COPY --from=builder /srv/jekyll/public /usr/share/nginx/html
