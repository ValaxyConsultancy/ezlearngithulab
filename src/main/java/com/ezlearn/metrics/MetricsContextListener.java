package com.ezlearn.metrics;

import io.micrometer.core.instrument.binder.jvm.ClassLoaderMetrics;
import io.micrometer.core.instrument.binder.jvm.JvmMemoryMetrics;
import io.micrometer.core.instrument.binder.jvm.JvmThreadMetrics;
import io.micrometer.core.instrument.binder.logging.LogbackMetrics;
import io.micrometer.core.instrument.binder.system.ProcessorMetrics;
import io.micrometer.core.instrument.binder.system.UptimeMetrics;
import io.micrometer.core.instrument.binder.tomcat.TomcatMetrics;
import io.micrometer.prometheus.PrometheusMeterRegistry;
import io.micrometer.prometheus.PrometheusConfig;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import org.apache.catalina.Manager;

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

        // Assuming you have a method to get the Manager instance
        Manager manager = getManagerFromContext(sce.getServletContext());
        new TomcatMetrics(manager, null).bindTo(prometheusRegistry);

        sce.getServletContext().setAttribute("prometheusRegistry", prometheusRegistry);
        sce.getServletContext().addServlet("metricsServlet", new MetricsServlet(prometheusRegistry)).addMapping("/metrics");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Clean up if necessary
    }

    private Manager getManagerFromContext(javax.servlet.ServletContext context) {
        return (Manager) context.getAttribute("org.apache.catalina.Manager");
    }
}
