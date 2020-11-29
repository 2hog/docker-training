FROM jekyll/jekyll as dev
COPY Gemfile Gemfile.lock /srv/jekyll/
RUN gem install bundler:1.16.4 && \
    bundle install

FROM dev as builder
COPY ./ /srv/jekyll/
RUN jekyll build

FROM nginx:alpine
COPY --from=builder /srv/jekyll/public /usr/share/nginx/html
