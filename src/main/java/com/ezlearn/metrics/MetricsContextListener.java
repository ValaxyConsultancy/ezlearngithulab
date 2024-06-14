package com.ezlearn.metrics;

import io.micrometer.core.instrument.binder.jvm.ClassLoaderMetrics;
import io.micrometer.core.instrument.binder.jvm.JvmMemoryMetrics;
import io.micrometer.core.instrument.binder.jvm.JvmThreadMetrics;
import io.micrometer.core.instrument.binder.logging.LogbackMetrics;
import io.micrometer.core.instrument.binder.system.ProcessorMetrics;
import io.micrometer.core.instrument.binder.system.UptimeMetrics;
import io.micrometer.core.instrument.binder.tomcat.TomcatMetrics;
import io.micrometer.prometheus.PrometheusConfig;
import io.micrometer.prometheus.PrometheusMeterRegistry;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import org.apache.catalina.Manager;
import javax.management.MBeanServer;
import java.lang.management.ManagementFactory;
import java.util.Collections;

@WebListener
public class MetricsContextListener implements ServletContextListener {

    private final PrometheusMeterRegistry prometheusRegistry;

    public MetricsContextListener() {
        this.prometheusRegistry = new PrometheusMeterRegistry(PrometheusConfig.DEFAULT);
    }

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        new ClassLoaderMetrics().bindTo(prometheusRegistry);
        new JvmMemoryMetrics().bindTo(prometheusRegistry);
        new JvmThreadMetrics().bindTo(prometheusRegistry);
        new LogbackMetrics().bindTo(prometheusRegistry);
        new ProcessorMetrics().bindTo(prometheusRegistry);
        new UptimeMetrics().bindTo(prometheusRegistry);

        // Get the Manager instance from your Tomcat context
        Manager manager = ...; // Obtain the Manager instance from your application context
        MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
        new TomcatMetrics(manager, Collections.emptyList(), mBeanServer).bindTo(prometheusRegistry);

        sce.getServletContext().setAttribute("prometheusRegistry", prometheusRegistry);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Clean up if necessary
    }
}
