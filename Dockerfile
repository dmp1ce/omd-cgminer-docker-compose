FROM ubuntu:16.04 as check_cgminer

# Get Stack
RUN apt-get update && apt-get install -y curl
RUN bash -c "curl -sSL https://get.haskellstack.org/ | sh"

# Get check_cgminer source and build
RUN git clone https://github.com/dmp1ce/check_cgminer.git
RUN cd check_cgminer && stack build --copy-bins

FROM consol/omd-labs-ubuntu

RUN echo "Install python-passlib for changing user passwords and python-pip for telegram notifications"\
 && apt-get update && apt-get install -y python-passlib python-pip\
 && pip install twx.botapi\
 && echo "Download nagios Telegram notification script"\
 && git clone https://github.com/pommi/telegram_nagios.git /opt/telegram_nagios\
 && ln -s /opt/telegram_nagios/telegram_nagios.py /usr/local/bin/telegram_nagios.py\
 && echo "Cleanup to reduce size of image"\
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add check_cgminer
COPY --from=check_cgminer /root/.local/bin/check_cgminer /usr/local/bin/check_cgminer
