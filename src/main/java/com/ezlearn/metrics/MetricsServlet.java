package com.ezlearn.metrics;

import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.exporter.common.TextFormat;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.Writer;

public class MetricsServlet extends HttpServlet {

    private final CollectorRegistry registry;

    public MetricsServlet(CollectorRegistry registry) {
        this.registry = registry;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setContentType(TextFormat.CONTENT_TYPE_004);
        try (Writer writer = resp.getWriter()) {
            TextFormat.write004(writer, registry.metricFamilySamples());
            writer.flush();
        }
    }
}
